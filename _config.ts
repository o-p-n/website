import lume from "lume/mod.ts";
import date from "lume/plugins/date.ts";
import relations from "lume/plugins/relations.ts";
import sass from "lume/plugins/sass.ts";

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

site.copyRemainingFiles();
site.copy("assets");
site.copy(".well-known");

export default site;
