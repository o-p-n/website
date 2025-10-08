import callouts from "markdown-it-callouts";
import sections from "markdown-it-header-sections";
import footnotes from "lume-md/footnotes.ts";
import toc from "lume-md/toc.ts";

import Site from "lume/core/site.ts";

export default function md() {
  return (site: Site) => {
    site.hooks.addMarkdownItPlugin(callouts, {
      defaultElementType: "blockquote",
      calloutTitleElementType: "h6",
      emptyTitleFallback: "match-type",
      calloutSymbols: {
        "note": "\ue34c",
        "tip": "\ue2dc",
        "important": "\ue9b8",
        "warning": "\ue4e0",
        "caution": "\ue4e4",
      },
    });
    site.hooks.addMarkdownItPlugin(sections);

    site.use(footnotes());
    site.use(toc({
      level: 1,
      anchor: false,
    }));
  };
}