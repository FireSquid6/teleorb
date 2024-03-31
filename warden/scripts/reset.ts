// starts the warden server for production
// does not seed anything
import { getAuth } from "@/auth";
import { getDb } from "@/db";
import { startApp, type ApiContext } from "@/index";
import fs from "fs";

if (fs.existsSync("warden.db")) {
  fs.rmSync("warden.db");
}

const db = getDb();
const context: ApiContext = {
  db,
  auth: getAuth(db),
  mode: "testing",
};

startApp(context);
