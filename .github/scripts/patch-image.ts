import { Octokit } from "npm:octokit@3.1.2";
import { $ } from "https://deno.land/x/dax@0.37.1/mod.ts";

class Repository {
  readonly owner: string;
  readonly repo: string;

  constructor(owner: string, repo: string) {
    this.owner = owner;
    this.repo = repo;
  }

  static from(full: string | Repository): Repository {
    if (typeof full === "string") {
      const [org, repo] = full.split("/", 2);
      return new Repository(org, repo);
    }
    return full;
  }

  toObject() {
    return {
      owner: this.owner,
      repo: this.repo,
    };
  }

  toString() {
    return `${this.owner}/${this.repo}`;
  }
}

interface TreeEntry {
  type: "blob",
  path: string,
  mode?: "100644" | undefined,
  content?: string | undefined,
  sha?: string | null | undefined,
}

class Patcher {
  #api: Octokit;

  readonly repo: Repository;
  readonly base: string;

  constructor(full: string | Repository, target: string, auth: string) {
    this.repo = Repository.from(full);
    this.base = target;

    this.#api = new Octokit({
      auth,
    });
  }

  async checkStatus() {
    const result: TreeEntry[] = [];
    const retval = await $`git status --porcelain`
      .stdout("piped");
    for (let line of retval.stdout.split("\n")) {
      line = line.trim();
      if (!line) { continue; }

      const [mode, path] = line.trim().split(/\s+/g, 2);
      if (!path || path.endsWith("deno.lock")) {
        // skipping empty path and lockfile ...
        continue;
      }

      const content = await (async (mode: string) => {
        switch (mode) {
          case "D": // deleted file
            console.log(`    🚫 deleting ${path}`)
            return null;
          case "M": // modified/updated file
            console.log(`    💾 modifying ${path}`);
            return await Deno.readTextFile(path);
          case "??": // added file
            console.log(`    💾 adding ${path}`);
            return await Deno.readTextFile(path);
          default:
            throw new Error(`unexpected status mode: ${mode}`);
        }
      })(mode);
  
      const entry = {
        path,
        content,
      } as TreeEntry;
      result.push(entry);
    }
  
    return result;
  }

  async createTree(base_tree: string, entries: TreeEntry[]) {
    const tree = entries.map((e): TreeEntry => {
      const base: TreeEntry = {
        type: "blob",
        path: e.path,
      };

      if (e.content === null) {
        return {
          ...base,
          sha: null,
        };
      }
      return {
        ...base,
        content: e.content,
        mode: "100644",
      };
    });

    const rsp = await this.#api.request("POST /repos/{owner}/{repo}/git/trees", {
      ...this.repo.toObject(),
      base_tree,
      tree,
    });

    return rsp.data;
  }

  async getCommit(sha: string) {
    const rsp = await this.#api.request("GET /repos/{owner}/{repo}/git/commits/{sha}", {
      ...this.repo.toObject(),
      sha,
    });

    return rsp.data;
  }

  async createCommit(tree: string, ...parents: string[]) {
    const rsp = await this.#api.request("POST /repos/{owner}/{repo}/git/commits", {
      ...this.repo.toObject(),
      tree,
      parents,
      message: "update deployment",
    });

    return rsp.data;
  }

  async getBranch(ref: string) {
    const rsp = await this.#api.request("GET /repos/{owner}/{repo}/git/refs/heads/{ref}", {
      ...this.repo.toObject(),
      ref,
    });

    return rsp.data;
  }

  async createBranch(name: string, sha: string) {
    const rsp = await this.#api.request("POST /repos/{owner}/{repo}/git/refs", {
      ...this.repo.toObject(),
      ref: `refs/heads/${name}`,
      sha,
    });

    return rsp.data;
  }

  async updateBranch(name: string, sha: string) {
    const rsp = await this.#api.request("PATH /repos/{owner}/{repo}/git/refs/heads/{ref}", {
      ...this.repo.toObject(),
      ref: name,
      sha,
    });

    return rsp.data;
  }

  async createPR(head: string, title: string) {
    const rsp = await this.#api.rest.pulls.create({
      ...this.repo.toObject(),
      base: this.base,
      head,
      title,
    });

    return rsp.data;
  }

  async mergePR(pull_number: number) {
    const repo = this.repo;

    const query = await this.#api.graphql(`query { repository(owner: "${repo.owner}", name: "${repo.repo}") { pullRequest(number: ${pull_number}) { id } } }`);
    // deno-lint-ignore no-explicit-any
    const prId = (query as any).repository.pullRequest.id;

    const _result = await this.#api.graphql(`mutation { enablePullRequestAutoMerge(input: {pullRequestId: "${prId}", mergeMethod: SQUASH}) { clientMutationId } }`);
  }

  async run() {
    /**
     * INPUTS:
     *  - repository({owner}/{repo})
     *  - `main` HEAD commit sha
     * 
     * STEPS:
     *  1. check status for changes
     *    - if no changes, DONE
     *  2. create branch
     *    a. create `deploy-${sha}` tree
     *      - uplodas added/modified/deleted files
     *    b. create `deploy-${sha}` commit for tree
     *    c. create `deploy-${sha}` branch for commit
     *  3. Create and merge PR
     *    a. create PR with:
     *      - title: `deploy ${sha}`
     *      - body: ""
     *      - head: `deploy-${sha}`
     *      - base: "main"
     *    b. merge PR
     */

    console.log(`checking status of "${this.repo.toString()}" on branch "${this.base}"...`);
    // STEP 1: check status
    const status = await this.checkStatus();
    if (status.length === 0) {
      console.log("... no changes detected!");
      return;
    }

    // obtain baseline
    const baseRef = await this.getBranch(this.base);
    const baseCommit = await this.getCommit(baseRef.object.sha);
    const fullSha = baseCommit.sha;

    // calculate a "short sha"
    const shortSha = fullSha.substring(0, 8);
    console.log(`create PR to deploy ${fullSha} ...`);

    console.log("🌳 save changes ...");
    // STEP 2: create deploy branch
    // STEP 2.a: create tree
    const tree = await this.createTree(baseCommit.tree.sha,  status);
    console.log(`... saved to ${tree.sha}`);

    console.log("🔒 create commit of changes ...");
    // STEP 2.b: create commit
    const commit = await this.createCommit(tree.sha, baseCommit.sha);
    console.log(`... commit ${commit.sha} created (verified? ${commit.verification.verified})`);

    console.log("📦 create branch of commit ...");
    // STEP 2.c: create branch
    const head = `deploy-${shortSha}`;
    const _branch = await this.createBranch(head, commit.sha);
    console.log(`... created branch ${head}`);

    console.log(`🚚 create PR for ${head}...`);
    // STEP 3: create + merge PR
    // STEP 3.a: create PR
    const pr = await this.createPR(head, `chore: deploy ${shortSha}`, );
    console.log(`... created PR ${pr.number}`);

    console.log(`🚀 merge PR ${pr.number} ...`);
    // STEP 3.b: merge PR
    await this.mergePR(pr.number);
    console.log("... merge requested");

    console.log("🎉 DONE");
  }
}

if (import.meta.main) {
  const auth = Deno.env.get("GITHUB_TOKEN");
  if (!auth) {
    console.log("access token not set (GITHUB_TOKEN)");
    Deno.exit(10);
  }
  const repository = Deno.env.get("GITHUB_REPOSITORY");
  if (!repository) {
    console.log("repository not found (GITHUB_REPOSITORY)");
    Deno.exit(11);
  }
  const baseRef = Deno.env.get("GITHUB_REF_NAME");
  if (!baseRef) {
    console.log("reference not found (GITHUB_REF_NAME)");
    Deno.exit(12);
  }

  const patcher = new Patcher(
    repository,
    baseRef,
    auth,
  );
  await patcher.run();
}
