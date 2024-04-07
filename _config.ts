import lume from "lume/mod.ts";
import date from "lume/plugins/date.ts";
import sass from "lume/plugins/sass.ts";

import markdown from "./_config/markdown.ts";

const site = lume({
  src: "src",
}, { markdown });

site.use(date());
site.use(sass({
  format: "expanded",
}));

site.copyRemainingFiles();
site.copy("assets");
site.copy(".well-known");

export default site;
