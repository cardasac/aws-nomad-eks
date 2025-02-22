import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  // discardResponseBodies: true,
  thresholds: {
    http_req_failed: [{ threshold: "rate<0.01" }],
    http_req_duration: [{ threshold: "p(99)<500" }],
  },
  scenarios: {
    contacts: {
      executor: "ramping-vus",
      startVUs: 900,
      stages: [{ duration: "15m", target: 1200 }],
      gracefulRampDown: "0s",
    },
  },
};

export default function () {
  const res = http.get(`https://${__ENV.HOST}`);
  check(res, { "status was 200": (r) => r.status == 200 });
  sleep(0.5);
}
