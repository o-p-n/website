import { format } from "npm:date-fns@3.6.0";
import { UTCDate } from "npm:@date-fns/utc@1.2.0";

import Site from "lume/core/site.ts";

const FORMAT = "yyyy-MM-dd'T'HH:mm:ssXXX";

export default function dateFormatter() {
  return (site: Site) => {
    site.filter("utcdate", filter);

    function filter(
      date: string | Date,
      pattern = FORMAT,
    ) {
      if (date === "now") {
        date = new Date();
      } else if (typeof date === "string") {
        date = new Date(date);
      }
      date = new UTCDate(date);

      return format(date, pattern);
    }
  }
}