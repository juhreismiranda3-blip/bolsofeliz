# 🐷 Bolso Feliz

Controle financeiro do casal, divertido e automático.

- Frases engraçadas quando o dinheiro está acabando ou a dívida está alta
- Confete quando entra um valor bom, quando todas as contas do mês são pagas e quando uma dívida é quitada
- Sobra prevista, termômetro do mês, contas atrasadas, gráfico por categoria
- Dados salvos no **Supabase** (PostgreSQL), com login por e-mail e senha
- Atualização ao vivo: o que um anota aparece na hora para o outro
- Botão para baixar uma cópia de segurança em planilha (CSV)

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `index.html` | O app inteiro (tela, frases, confete, regras) |
| `config.js` | Endereço e chave pública do seu projeto Supabase |
| `supabase/schema.sql` | Cria as tabelas e as regras de segurança no banco |

## Como colocar no ar

### 1. Banco de dados (Supabase)
1. Crie uma conta em supabase.com e um projeto novo (plano Free).
2. Abra **SQL Editor**, cole todo o conteúdo de `supabase/schema.sql` e clique em **Run**.
3. Ainda no SQL Editor, rode (com os e-mails de vocês):
   ```sql
   insert into public.membros (email) values
     ('seu-email@gmail.com'),
     ('email-dele@gmail.com')
   on conflict do nothing;
   ```
4. Em **Authentication › Users › Add user › Create new user**, crie um usuário para cada um, com a senha que quiserem, e marque **Auto Confirm User**.
5. Em **Authentication › Sign In / Providers**, desligue **Allow new users to sign up**, para ninguém mais criar conta.
6. Em **Project Settings › API**, copie o **Project URL** e a chave **anon / publishable**.

### 2. Configuração
Abra `config.js` e cole os dois valores no lugar de `COLE_AQUI...`.

> A chave anon/publishable pode ficar pública: quem protege os dados são as regras de segurança (RLS).
> **Nunca** coloque a chave `service_role` / `secret` neste arquivo.

### 3. GitHub Pages
1. No GitHub, crie um repositório **bolso-feliz** (público, para o Pages gratuito).
2. Clique em **uploading an existing file** e arraste `index.html`, `config.js`, `README.md` e a pasta `supabase`.
3. Em **Settings › Pages**, escolha **Deploy from a branch**, branch **main**, pasta **/ (root)** e salve.
4. Em 1 ou 2 minutos o app fica em `https://SEU-USUARIO.github.io/bolso-feliz/`.

## Segurança
- Só os e-mails da tabela `membros` conseguem ler ou gravar qualquer coisa.
- Um usuário logado que não esteja na lista não vê nada e não consegue gravar.
- O código pode ser público sem expor os dados.

## Para adicionar mais alguém
Inclua o e-mail na tabela `membros` e crie o usuário em **Authentication › Users**.
