import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import * as schema from "./schema";

export const DRIZZLE = "DRIZZLE";

export const databaseProviders = [
  {
    provide: DRIZZLE,
    useFactory: async () => {
      const pool = new Pool({
        connectionString: process.env.DATABASE_URL,
      });
      return drizzle(pool, { schema });
    },
  },
];
