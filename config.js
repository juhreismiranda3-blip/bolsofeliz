// Configuração do Bolso Feliz
// Copie estes dois valores do Supabase: Project Settings › API (ou Data API)
// A chave "anon" / "publishable" pode ficar pública: quem protege os dados
// são as regras de segurança (RLS) criadas pelo arquivo supabase/schema.sql.
// NUNCA coloque aqui a chave "service_role" / "secret".

window.BOLSO_CONFIG = {
  SUPABASE_URL: "COLE_AQUI_O_PROJECT_URL",
  SUPABASE_ANON_KEY: "COLE_AQUI_A_CHAVE_ANON_OU_PUBLISHABLE"
};
