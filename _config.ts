import lume from "lume/mod.ts";
import sass from "lume/plugins/sass.ts";
import readingInfo from "lume/plugins/reading_info.ts";
import highlight from "lume/plugins/code_highlight.ts";

import utcdate from "./_config/utcdate.ts";
import markdown from "./_config/markdown.ts";

const site = lume({
  src: "./src",
});

site.mergeKey("site", "object");

site.use(markdown());
site.use(utcdate());
site.use(sass({
  format: "expanded",
}));
site.use(readingInfo());
site.use(highlight({
  theme: [
    {
      name: "atom-one-dark-reasonable",
      cssFile: "/styles/highlight-dark.css",
      placeholder: "/* dark theme */",
    },
    {
      name: "atom-one-light",
      cssFile: "/styles/highlight-light.css",
      placeholder: "/* light theme */",
    }
  ],
}));

site.add("/styles");
site.add("/assets");
site.add("/.well-known");

export default site;
