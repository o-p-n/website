import lume from "lume/mod.ts";
import date from "lume/plugins/date.ts";
import relations from "lume/plugins/relations.ts";
import sass from "lume/plugins/sass.ts";
import nunjucks from "lume/plugins/nunjucks.ts";

import mdContainer from "markdown-it-container";
import mdFootnote from "markdown-it-footnote";

import $ from "dax";

const markdown = {
  plugins: [
    [mdContainer, "callout"],
    mdFootnote,
  ],
  keepDefaultPlugins: true,
};

const site = lume({
  src: "src",
}, { markdown });

site.use(date());
site.use(relations());
site.use(sass({
  format: "expanded",
}));
site.use(nunjucks());
site.preprocess([".md"], async (pages) => {
  for (const p of pages) {
    const path = p.src.entry?.src || "";
    if (!path) { continue }
    const gitUnix = await $`git log --pretty=%ct -n 1 -- src${p.src.path}${p.src.ext}`.text();
    const git = new Date(parseInt(gitUnix) * 1000);
    p.data.date = git;
    console.log(`date for ${p.src.path} is ${p.data.date.toISOString()}`);
  }
});

site.copyRemainingFiles();
site.copy("assets");
site.copy(".well-known");

export default site;
