// resumes the warden server wherever it was left off
import { getAuth } from "@/auth";
import { getDb } from "@/db";
import { startApp, type ApiContext } from "@/index";

const db = getDb();
const context: ApiContext = {
  db,
  auth: getAuth(db),
  mode: "production",
};

startApp(context);
