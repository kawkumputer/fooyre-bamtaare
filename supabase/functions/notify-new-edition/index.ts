// Edge Function : envoie une notification push (FCM) a tous les
// appareils abonnes au topic "new_editions" des qu'une nouvelle
// edition est inseree dans la table public.editions.
//
// Declenchee par un Database Webhook Supabase (Database > Webhooks)
// sur INSERT dans "editions", configure pour appeler cette fonction.
//
// Secret requis (Edge Functions > Manage secrets) :
//   FIREBASE_SERVICE_ACCOUNT_JSON = contenu complet du fichier JSON
//   de compte de service genere dans Firebase Console
//   (Project Settings > Cloud Messaging > Comptes de service).

const FIREBASE_PROJECT_ID = "fooyre-20770";
const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

function base64url(input: Uint8Array | string): string {
  const bytes =
    typeof input === "string" ? new TextEncoder().encode(input) : input;
  let str = "";
  for (const b of bytes) str += String.fromCharCode(b);
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/** Echange le compte de service Firebase contre un token OAuth2 (JWT
 * signe RS256), pour appeler l'API FCM HTTP v1. */
async function getAccessToken(serviceAccount: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: serviceAccount.client_email,
    scope: FCM_SCOPE,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const signingInput = `${base64url(JSON.stringify(header))}.${base64url(
    JSON.stringify(claims),
  )}`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput),
  );
  const jwt = `${signingInput}.${base64url(new Uint8Array(signature))}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Echec obtention token OAuth: ${JSON.stringify(data)}`);
  }
  return data.access_token as string;
}

Deno.serve(async (req: Request) => {
  try {
    const payload = await req.json();
    // Format standard d'un Database Webhook Supabase.
    const record = payload.record ?? payload.new ?? payload;
    const numero = record?.numero;
    const titre = record?.titre ?? "Fooyre Ɓamtaare";

    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
    if (!serviceAccountJson) {
      return new Response(
        JSON.stringify({ error: "FIREBASE_SERVICE_ACCOUNT_JSON manquant" }),
        { status: 500 },
      );
    }
    const serviceAccount = JSON.parse(serviceAccountJson);
    const accessToken = await getAccessToken(serviceAccount);

    const title = "Nouvelle édition / Tonngoode hesere";
    const body = numero ? `N°${numero} — ${titre}` : titre;

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            topic: "new_editions",
            notification: { title, body },
          },
        }),
      },
    );
    const fcmData = await fcmRes.json();
    if (!fcmRes.ok) {
      console.error("Erreur envoi FCM:", fcmData);
      return new Response(JSON.stringify(fcmData), { status: 500 });
    }

    return new Response(JSON.stringify({ ok: true, fcm: fcmData }), {
      status: 200,
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
    });
  }
});
