import callouts from "markdown-it-callouts";
import sections from "markdown-it-header-sections";
import footnotes from "lume-md/footnotes/mod.ts";

const markdown = {
  plugins: [
    [callouts, {
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
    }],
    sections,
    footnotes,
  ],
};

export default markdown;
