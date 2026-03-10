import { and, eq } from 'drizzle-orm';
import axios from 'axios';
import { egovTokens } from '@workflow/database';
import { getDb } from './db';

export async function getOrRefreshEgovToken(input: {
  serviceName: string;
}): Promise<{ accessToken: string; tokenType: string }> {
  const database = getDb();

  const bufferMs = 5 * 60 * 1000;
  const now = new Date();
  const bufferDate = new Date(now.getTime() + bufferMs);

  const [existing] = await database
    .select()
    .from(egovTokens)
    .where(
      and(
        eq(egovTokens.serviceName, input.serviceName),
        eq(egovTokens.isActive, true),
      ),
    )
    .limit(1);

  if (existing && existing.accessTokenExpiresAt > bufferDate) {
    return {
      accessToken: existing.accessToken,
      tokenType: existing.tokenType,
    };
  }

  const tokenUrl = process.env.EGOV_TOKEN_URL!;
  const consumerKey = process.env.EGOV_CONSUMER_KEY!;
  const consumerSecret = process.env.EGOV_CONSUMER_SECRET!;
  const username = process.env.EGOV_USERNAME!;
  const password = process.env.EGOV_PASSWORD!;

  const basicAuth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString(
    'base64',
  );

  const response = await axios.post(
    tokenUrl,
    new URLSearchParams({
      grant_type: 'password',
      username,
      password,
    }).toString(),
    {
      headers: {
        Authorization: `Basic ${basicAuth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    },
  );

  const { access_token, expires_in, token_type } = response.data;

  if (existing) {
    await database
      .update(egovTokens)
      .set({ isActive: false, updatedAt: new Date() })
      .where(
        and(
          eq(egovTokens.serviceName, input.serviceName),
          eq(egovTokens.isActive, true),
        ),
      );
  }

  const expiresAt = new Date(now.getTime() + expires_in * 1000);

  await database.insert(egovTokens).values({
    serviceName: input.serviceName,
    accessToken: access_token,
    accessTokenExpiresAt: expiresAt,
    expiresIn: expires_in,
    tokenType: token_type || 'Bearer',
    isActive: true,
    metadata: { refreshedAt: now.toISOString() },
  });

  return {
    accessToken: access_token,
    tokenType: token_type || 'Bearer',
  };
}
