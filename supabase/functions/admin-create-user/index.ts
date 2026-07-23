// Edge Function : cree un compte lecteur (auth.users + profiles via le
// trigger handle_new_user existant) a la demande de l'admin, avec un mot
// de passe temporaire genere aleatoirement.
//
// Remplace l'inscription en libre-service (RegisterScreen, retiree de
// l'app) : suite au retour App Store guideline 3.1.1/3.1.3(a), une
// "Reader App" ne doit pas permettre a n'importe quel visiteur de creer
// un compte donnant acces a du contenu payant. La creation de compte
// reste possible, mais uniquement depuis l'ecran admin (deja
// authentifie), jamais depuis un ecran visible d'un utilisateur anonyme.
//
// Appelee via supabase.functions.invoke('admin-create-user', ...) avec
// la session de l'admin connecte. Aucun secret a configurer : les
// variables SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY
// sont fournies automatiquement par la plateforme Edge Functions.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function generatePassword(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
  const bytes = new Uint8Array(12);
  crypto.getRandomValues(bytes);
  let pw = "";
  for (const b of bytes) pw += chars[b % chars.length];
  return pw;
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Methode non autorisee" }), {
        status: 405,
      });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Non authentifie" }), {
        status: 401,
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Identifie l'appelant a partir de son propre jeton de session.
    const callerClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user: caller },
      error: callerError,
    } = await callerClient.auth.getUser();
    if (callerError || !caller) {
      return new Response(JSON.stringify({ error: "Session invalide" }), {
        status: 401,
      });
    }

    // Client service_role : verifie le role admin puis cree le compte.
    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: callerProfile, error: profileError } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", caller.id)
      .single();
    if (profileError || callerProfile?.role !== "admin") {
      return new Response(JSON.stringify({ error: "Non autorise" }), {
        status: 403,
      });
    }

    const { email, nom, telephone } = await req.json();
    if (!email || !nom) {
      return new Response(
        JSON.stringify({ error: "email et nom requis" }),
        { status: 400 },
      );
    }

    const password = generatePassword();
    const { error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { nom, telephone: telephone || null },
    });
    if (createError) {
      return new Response(JSON.stringify({ error: createError.message }), {
        status: 400,
      });
    }

    return new Response(JSON.stringify({ ok: true, password }), {
      status: 200,
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
    });
  }
});
