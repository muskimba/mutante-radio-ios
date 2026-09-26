# Mutante Radio — app iOS

App da **Mutante Radio** (Flutter) — versão isolada para **publicação na App Store**.

> Este repositório é um **recorte só da parte iOS** de um app Flutter. O código
> Dart (`lib/`) é o mesmo que roda no Android; aqui vem só o wrapper iOS
> (`ios/`), pronto pra compilar num Mac / na nuvem e enviar pro TestFlight e
> App Store. A parte Android fica em outro repositório privado.

## O que o app faz

Mostra o site **mutanteradio.com** ao vivo dentro de um WebView + um **player de
áudio nativo** por baixo (toca em segundo plano, com controles na notificação /
tela de bloqueio). Detalhes da arquitetura nos arquivos de `lib/`:

| Arquivo | Papel |
|---|---|
| `lib/main.dart` | inicialização, tema |
| `lib/config.dart` | URLs (site, stream, "tocando agora") |
| `lib/home_page.dart` | WebView + injeção de CSS que esconde o player do site |
| `lib/radio_service.dart` | player `just_audio` + metadados |
| `lib/player_bar.dart` / `lib/now_playing_sheet.dart` | UI do player nativo |

## Pré-requisitos

- **macOS + Xcode** (obrigatório pra compilar iOS — restrição da Apple)
- **Conta Apple Developer** — US$ 99/ano (https://developer.apple.com/programs/)
- [Flutter](https://docs.flutter.dev/get-started/install) 3.19+ e CocoaPods

## Rodar / testar localmente (num Mac)

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

No Xcode: **Runner → Signing & Capabilities** → selecionar o seu *Team*. O
`Info.plist` já vem com `UIBackgroundModes: audio` (necessário pro áudio em
segundo plano).

## Identificador

- **Bundle ID atual:** `com.mutanteradio.mutanteRadio`
- Troque pelo identificador do seu time Apple se preferir, em:
  - `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`)
  - `ios/fastlane/Appfile` e `ios/fastlane/Fastfile` (`APP_ID`)
  - `codemagic.yaml` (`bundle_identifier`)

## Publicar

### Opção A — build local (Mac)

```bash
flutter build ipa --release
# envie build/ios/ipa/*.ipa pelo app Transporter ou Xcode → Organizer
```

### Opção B — GitHub Actions (Mac na nuvem, grátis se o repo for público)

Workflow pronto em [`.github/workflows/ios-testflight.yml`](.github/workflows/ios-testflight.yml):
compila, assina (assinatura automática via App Store Connect API key) e envia
pro **TestFlight**. Assinatura via fastlane em [`ios/fastlane/`](ios/fastlane).

1. **App Store Connect → Users and Access → Integrations → App Store Connect API**
   → *Generate API Key* (papel **App Manager**) → baixe o `AuthKey_XXXXX.p8`
   (só dá pra baixar 1 vez). Anote o **Key ID** e o **Issuer ID**.
2. Pegue o **Team ID** em Apple Developer → *Membership details*.
3. Registre o **App ID** em Certificates, Identifiers & Profiles e crie o app em
   App Store Connect (nome "Mutante Radio", o bundle ID, um SKU).
4. No GitHub: **Settings → Secrets and variables → Actions** → adicione:

   | Secret | Valor |
   |---|---|
   | `ASC_KEY_ID` | o Key ID |
   | `ASC_ISSUER_ID` | o Issuer ID (UUID) |
   | `ASC_KEY_P8` | o conteúdo do `.p8` **em base64** |
   | `APPLE_TEAM_ID` | o Team ID (10 caracteres) |

5. **Actions → iOS → TestFlight → Run workflow** → ~15-20 min → build no TestFlight.

### Opção C — Codemagic

Alternativa pronta em [`codemagic.yaml`](codemagic.yaml) (também Mac na nuvem,
free tier 500 min/mês).

## Ficha da App Store

- **Ícone 1024×1024:** use `assets/icon/icon.png` (já está nesse tamanho, sem
  transparência)
- **Screenshots:** gere automaticamente pelo workflow
  [`.github/workflows/ios-screenshots.yml`](.github/workflows/ios-screenshots.yml)
  — **Actions → "Screenshots iOS (App Store)" → Run workflow**. Roda num
  simulador de verdade no Mac da nuvem, **sem precisar de conta Apple nem
  assinatura de código** (pode rodar antes mesmo de ter a conta criada). O
  resultado fica em *Artifacts* no final da execução, pronto pra subir no App
  Store Connect. As screenshots do projeto Android **não servem** (dimensões
  e chrome de sistema diferentes).
- **Política de privacidade:** [`store/privacy-policy.html`](store/privacy-policy.html)
  — hospede numa URL pública e informe no App Store Connect. O app não coleta dados.

## ⚠️ Nota sobre a guideline 4.2 ("minimum functionality")

Apps que são "só um site num WebView" às vezes tomam rejeição da Apple. Este app
tem funcionalidade nativa real (player em segundo plano, controles de mídia,
ficha de letra da música) — descreva bem isso nas notas para o revisor (texto
pronto logo abaixo).

## Textos da ficha (prontos pra copiar e colar)

**Nome** (máx. 30 caracteres)
```
Mutante Radio
```

**Subtítulo** (máx. 30 caracteres)
```
Rádio independente ao vivo
```

**Texto promocional** (máx. 170 caracteres — único campo que dá pra atualizar
depois **sem** precisar de nova revisão)
```
Punk, hardcore, pós-punk, garage e psicodelia — ao vivo, 24h. Veja a música tocando com capa e letra, e continue ouvindo com a tela desligada.
```

**Descrição** (máx. 4000 caracteres)
```
A Mutante Radio no seu bolso.

Ouça ao vivo a rádio mais independente, underground, alternativa e mutante que
você já ouviu na vida — punk, hardcore, pós-punk, garage, surf, psicodelia e
tudo que foge do óbvio, sem parar.

• Toque com um botão e ouça a transmissão ao vivo
• Veja o programa / música / artista tocando agora, com a capa e a letra
• Notícias, eventos, vídeos e podcasts direto do site mutanteradio.com
• Continua tocando com o app em segundo plano e a tela desligada
• Controles na tela de bloqueio
• Leve, sem cadastro, sem anúncios

Sintonize e fique mutante.

mutanteradio.com
```

**Palavras-chave** (máx. 100 caracteres, separadas por vírgula, sem espaço
depois da vírgula)
```
rádio,punk,rock,underground,independente,streaming,música,hardcore,alternativo,ao vivo
```

**Categoria:** Música (principal) · Estilo de vida (secundária, opcional)

**URL de suporte:** `https://www.mutanteradio.com` (ou um e-mail de contato)

**Notas para o revisor** (campo "App Review Information → Notes" — é onde se
antecipa a questão da guideline 4.2)
```
O app mostra o site mutanteradio.com num WebView, mas tem funcionalidade
nativa real além disso: um player de áudio que toca a transmissão ao vivo da
rádio, continua tocando com o app em segundo plano e a tela desligada, mostra
controles de mídia na tela de bloqueio e exibe a letra da música tocando no
momento. O app não tem cadastro, login nem coleta de dados — é só o player +
o conteúdo do site da rádio.
```
