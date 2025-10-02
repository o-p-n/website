import footnote from "markdown-it-footnote";
import callouts from "markdown-it-callouts";

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
    footnote,
  ],
};

export default markdown;
