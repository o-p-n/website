import lume from "lume/mod.ts";
import date from "lume/plugins/date.ts";
import relations from "lume/plugins/relations.ts";
import sass from "lume/plugins/sass.ts";
import nunjucks from "lume/plugins/nunjucks.ts";

import mdContainer from "markdown-it-container";
import mdFootnote from "markdown-it-footnote";

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
    const stat = await Deno.stat(path);
    console.log(`${p.src.path} times: created=${stat.birthtime?.toISOString()}, modified=${stat.mtime?.toISOString()}`);
  }
});

site.copyRemainingFiles();
site.copy("assets");
site.copy(".well-known");

export default site;
