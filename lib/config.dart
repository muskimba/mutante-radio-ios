/// Configuração central do app v2.
class Config {
  static const stationName = 'Mutante Radio';

  /// O site que o app "clona" — carregado num WebView. Mudou no site, mudou aqui.
  static const siteUrl = 'https://www.mutanteradio.com/';

  /// Domínios que abrem DENTRO do app (o resto abre no navegador do sistema).
  static const internalHosts = ['mutanteradio.com', 'www.mutanteradio.com'];

  /// Stream de áudio ao vivo (AAC, HTTPS).
  static const streamUrl = 'https://s30.maxcast.com.br:8190/live';

  /// "Tocando agora" (música, artista, capa, letra).
  static const statusUrl =
      'https://s30.maxcast.com.br/api/status/mutanteradio/current.json';

  static const fallbackCover =
      'https://social.maxcast.com.br/storage/network-logo/3b4fb1fa-545e-4cbc-93dc-a2a89debe148.jpg';

  static const pollInterval = Duration(seconds: 15);

  /// CSS/JS injetado no site: esconde o player embutido (usamos o nativo) e
  /// abre espaço embaixo pra barra do app.
  static const injectedJs = r'''
    (function () {
      var css = `
        .player-bottom, #jquery_jplayer_1 { display:none !important; }
        body { padding-bottom: 76px !important; }
      `;
      var s = document.createElement('style');
      s.textContent = css;
      document.head.appendChild(s);
      // silencia qualquer <audio> do site (o áudio é do player nativo)
      function killAudio() {
        document.querySelectorAll('audio').forEach(function (a) {
          try { a.pause(); a.muted = true; a.autoplay = false; a.src = ''; } catch (e) {}
        });
      }
      killAudio();
      new MutationObserver(killAudio).observe(document.documentElement, {childList:true, subtree:true});
    })();
  ''';
}
