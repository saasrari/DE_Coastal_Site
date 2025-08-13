function build_site()
% Build a simple docs website (HTML files) using only MATLAB.
% Writes into ./docs

clc; close all;
outDir  = fullfile(pwd,'docs');
assets  = fullfile(outDir,'assets');
if ~exist(outDir,'dir'), mkdir(outDir); end
if ~exist(assets,'dir'), mkdir(assets); end

% ---------- Site settings ----------
site.title      = 'Coastal Hazard Modeling';
site.org        = 'Your Research Group';
site.themeColor = '#0a2540';
site.pages = { ...
  'index','Home'; ...
  'objective','ABOUT'; ...
  'how','HOW TO USE THIS WEBSITE'; ...
  'models','BASIC MODEL INFORMATION'; ...
  'guide','USER GUIDE'; ...
  'sites','SITES'; ...
  'map','USER-INTERACTIVE MAP'; ...
  'demo','DEMONSTRATION'; ...
  'animation','ANIMATION'; ...
  'team','TEAM'; ...
  'publication','PUBLICATIONS/PRESENTATIONS'; ...
  'media','SOCIAL MEDIA'; ...
  'website','RELATED WEBSITE' ...
};

% ---------- Logo ----------
site.logo = 'logo.jpg';                      % set to your real file (logo.jpg/png)
logoPath  = fullfile(assets, site.logo);
if ~exist(logoPath,'file')
    warning('Logo file not found: %s', logoPath);
end

% ---------- Shared CSS ----------
cssPath = fullfile(assets,'style.css');
writeCSS(cssPath, site.themeColor);

% ---------- Content ----------
content.index = [ ...
  '<p><strong>Near-real-time modeling of total water levels and coastal change using XBeach and companion models.</strong></p>' ...
  '<p>This site shares model setup, user guides, sites, demos, and animations.</p>' ...
];
content.objective = '<p>Short project overview, goals, and scope.</p>';
content.how       = '<p>Explain navigation, search, and where to find results.</p>';

content.models = htmlList({ ...
  mklink('models_overview.html','Overview of Technology/Methodology'), ...
  mklink('models_xbeach.html','XBEACH') ...
});
content.guide = htmlList({ ...
  mklink('guide_xbeach.html','XBEACH USERS GUIDE') ...
});
content.sites = htmlList({ ...
  mklink('site_delaware.html','Delaware Coast') ...
});
content.map = [ ...
  '<p>Interactive map of the latest run.</p>' ...
  iframe('map_embed.html?v=1') ...   % cache-buster
];


content.demo        = '<p>Add demo pages for each site with images, GIFs, or short videos.</p>';
content.animation   = '<p>Link to or embed model result animations (GIF/MP4).</p>';
content.team        = '<ul><li>Your Name — PI</li><li>Colleague — Modeling</li></ul>';
content.publication = '<p>List citations, DOIs, slides, posters.</p>';
content.media       = '<p>Twitter/Threads/press links.</p>';
content.website     = '<p>Related projects and resources.</p>';

% ---------- Write main pages ----------
for i = 1:size(site.pages,1)
    slug  = site.pages{i,1};
    title = site.pages{i,2};
    body  = content.(slug);
    writePage(outDir, assets, site, slug, title, body, site.pages);
end

% ---------- Subpages: Models ----------
writeSimplePage(outDir, assets, site, 'models_overview', ...
    'Overview of Technology/Methodology', '<p>High-level comparison of models and when to use each.</p>', site.pages);
writeSimplePage(outDir, assets, site, 'models_xbeach', ...
    'XBEACH', '<p>Shortwave/longwave modes, parameters, morphology switches.</p>', site.pages);

% ---------- Subpages: Guides ----------
writeSimplePage(outDir, assets, site, 'guide_xbeach', ...
    'XBEACH — User Guide', '<p>Parameter tuning, grids, validation.</p>', site.pages);

% ---------- Site pages ----------
writeSimplePage(outDir, assets, site, 'site_delaware', ...
    'Delaware Coast', '<p>Describe locations, transects, and data sources.</p>', site.pages);

% ---------- Map page ----------
writeLeafletMap(outDir, assets);

fprintf('\nDone! Open: %s\n', fullfile(outDir,'index.html'));

% ========== Nested helper functions ==========

    function writePage(outDir_, assets_, site_, slug, title, body, pages)
        html = sprintf(['<!DOCTYPE html><html lang="en"><head>' ...
          '<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">' ...
          '<title>%s — %s</title>' ...
          '<link rel="icon" href="assets/%s">' ...
          '<link rel="stylesheet" href="assets/style.css">' ...
          '</head><body>' ...
          '<header class="site-header"><a class="brand" href="index.html">' ...
          '<img src="assets/%s" alt="Logo"><span>%s</span></a></header>' ...
          '<nav class="top-nav">%s</nav>' ...
          '<main class="container"><aside class="sidebar">%s</aside>' ...
          '<article class="content"><h1>%s</h1>%s</article></main>' ...
          '<footer class="site-footer">&copy; %d %s</footer>' ...
          '</body></html>'], ...
          title, site_.title, ...
          site_.logo, ...
          site_.logo, site_.title, ...
          topNav(pages, slug), sideNav(pages, slug), ...
          title, body, year(datetime('now')), site_.org);

        fid = fopen(fullfile(outDir_, [slug '.html']),'w');
        fwrite(fid, html);
        fclose(fid);
    end

    function writeSimplePage(outDir_, assets_, site_, slug, title, paragraph, pages)
        writePage(outDir_, assets_, site_, slug, title, paragraph, pages);
    end

    function s = topNav(pages, active)
        items = cell(1, size(pages,1));
        for ii = 1:size(pages,1)
            slug  = pages{ii,1};
            label = pages{ii,2};
            if strcmp(slug, active), cls = ' class="active"'; else, cls = ''; end
            items{ii} = sprintf('<a%s href="%s.html">%s</a>', cls, slug, label);
        end
        s = strjoin(items, '');
    end

    function s = sideNav(pages, active)
        items = cell(1, size(pages,1));
        for ii = 1:size(pages,1)
            slug  = pages{ii,1};
            label = pages{ii,2};
            if strcmp(slug, active), cls = ' class="active"'; else, cls = ''; end
            items{ii} = sprintf('<div><a%s href="%s.html">%s</a></div>', cls, slug, label);
        end
        s = strjoin(items, '');
    end

    function writeCSS(path, themeColor)
        css = [ ...
':root{--brand ', themeColor, ';--bg:#ffffff;--text:#1f2937;--muted:#6b7280;}', ...
'body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Helvetica,Arial,sans-serif;background:var(--bg);color:var(--text)}', ...
'.site-header{display:flex;align-items:center;gap:.6rem;padding:.8rem 1rem;border-bottom:1px solid #e5e7eb}', ...
'.brand{display:flex;align-items:center;gap:.6rem;color:var(--text);text-decoration:none;font-weight:600}', ...
'.brand img{height:28px}.top-nav{display:flex;gap:.8rem;flex-wrap:wrap;padding:.5rem 1rem;border-bottom:1px solid #e5e7eb}', ...
'.top-nav a{padding:.4rem .6rem;border-radius:.5rem;text-decoration:none;color:var(--text)}', ...
'.top-nav a.active,.top-nav a:hover{background:var(--brand);color:#fff}', ...
'.container{display:grid;grid-template-columns:260px 1fr;gap:1rem;align-items:start;padding:1rem;max-width:1200px;margin:0 auto}', ...
'.sidebar{position:sticky;top:10px;border:1px solid #e5e7eb;padding:1rem;border-radius:.75rem}', ...
'.sidebar a{display:block;color:var(--text);text-decoration:none;margin:.2rem 0}', ...
'.sidebar a.active{font-weight:600}', ...
'.content{padding:1rem 1.2rem;border:1px solid #e5e7eb;border-radius:.75rem}', ...
'img.align-right{float:right;margin:0 0 1rem 1rem;max-width:40%;height:auto}', ...
'.site-footer{padding:1rem;text-align:center;color:var(--muted);border-top:1px solid #e5e7eb;margin-top:2rem}', ...
'.content h1{margin-top:.2rem}' ...
        ];
        fid = fopen(path,'w'); fwrite(fid, css); fclose(fid);
    end

    function s = mklink(href, text_)
        s = ['<a href="', href, '">', text_, '</a>'];
    end

    function s = htmlList(items)
        li = cellfun(@(x) ['<li>', x, '</li>'], items, 'UniformOutput', false);
        s  = ['<ul>', strjoin(li,''), '</ul>'];
    end

    function s = iframe(src)
        s = ['<div style="border:1px solid #e5e7eb;border-radius:8px;overflow:hidden;height:520px">' ...
             '<iframe src="', src, '" style="width:100%;height:100%;border:0"></iframe></div>'];
    end

 function writeLeafletMap(outDir_, assets_)
    % Writes docs/map_embed.html
    % Robust loader: tries Leaflet from cdnjs, falls back to unpkg.
    % Shows status messages so you can see where it stops.

    geoDir = fullfile(outDir_, 'assets', 'geo');
    if ~exist(geoDir, 'dir'), mkdir(geoDir); end

    lines = {
'<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
'<title>Interactive Map</title>'
'<!-- Try both CSS CDNs (duplicates are harmless) -->'
'<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.css">'
'<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">'
'<style>'
'  html,body{margin:0;padding:0;height:100%}'
'  #map{height:100vh;margin:0}'
'  .leaflet-popup-content{max-width:560px !important}'
'  .popupimg{max-width:520px;width:100%;display:block;margin-top:6px;border-radius:6px;cursor:pointer}'
'  #status{position:fixed;top:8px;left:8px;background:#111;color:#fff;padding:6px 10px;border-radius:6px;opacity:.9;font:13px/1.2 system-ui,Segoe UI,Arial;z-index:1000}'
'</style>'
'</head><body>'
'<div id="map"></div>'
'<div id="status">Loading library…</div>'
'<script>'
'(function(){'
'  var statusEl=document.getElementById("status");'
'  function setStatus(s){ try{ statusEl.textContent=s; }catch(e){} }'
'  function start(){'
'    try{'
'      setStatus("Initializing map…");'
'      var map=L.map("map").setView([38.9,-75.2],8);'
'      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",{maxZoom:19,attribution:"© OpenStreetMap"}).addTo(map);'
'      setStatus("Loading markers…");'
'      fetch("assets/geo/latest_run.geojson").then(function(r){'
'        if(!r.ok) throw new Error("latest_run.geojson not found");'
'        return r.json();'
'      }).then(function(g){'
'        setStatus("Rendering features…");'
'        L.geoJSON(g,{onEachFeature:function(f,l){'
'          var p=f.properties||{};'
'          var html="<strong>"+(p.name||"Transect")+"</strong>";'
'          if(p.image){'
'            var im=String(p.image);'
'            html+="<br><a href=\\"" + im + "\\" target=\\"_blank\\" rel=\\"noopener\\"><img class=\\"popupimg\\" src=\\"" + im + "\\"></a>";'
'            html+="<div style=\\"margin-top:4px\\"><a href=\\"" + im + "\\" target=\\"_blank\\" rel=\\"noopener\\">Open full size</a></div>";'
'          }'
'          l.bindPopup(html,{maxWidth:560});'
'        }}).addTo(map);'
'        setStatus("Done."); setTimeout(function(){statusEl.style.display="none";},1500);'
'      }).catch(function(e){ setStatus("No GeoJSON yet: " + e.message); });'
'    }catch(e){ setStatus("Init error: " + e.message); }'
'  }'
'  function loadScript(src, onload, onerror){'
'    var s=document.createElement("script"); s.src=src; s.onload=onload; s.onerror=onerror; document.head.appendChild(s);'
'  }'
'  // Try cdnjs, then fall back to unpkg if blocked'
'  loadScript("https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.js", start, function(){'
'    setStatus("CDNJS blocked; trying unpkg…");'
'    loadScript("https://unpkg.com/leaflet@1.9.4/dist/leaflet.js", start, function(){'
'      setStatus("Failed to load Leaflet library.");'
'    });'
'  });'
'  // Surface any unexpected JS errors in the status pill'
'  window.addEventListener("error", function(e){ setStatus("JS error: " + (e.message||"unknown")); });'
'  window.addEventListener("unhandledrejection", function(e){ setStatus("Promise error: " + (e.reason&&e.reason.message?e.reason.message:e.reason)); });'
'})();'
'</script>'
'</body></html>'
    };

    fid = fopen(fullfile(outDir_,'map_embed.html'),'w');
    fwrite(fid, strjoin(lines,''));
    fclose(fid);
end



end
