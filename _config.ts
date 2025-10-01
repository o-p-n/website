import lume from "lume/mod.ts";
import sass from "lume/plugins/sass.ts";

import utcdate from "./_config/utcdate.ts";
import markdown from "./_config/markdown.ts";

const site = lume({
  src: "src",
}, { markdown });

site.use(utcdate());
site.use(sass({
  format: "expanded",
}));

site.add("/styles");
site.add("/assets");
site.add("/.well-known");

export default site;
