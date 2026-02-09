# Cosmic Troll Build Lab

Web app “troll” ma **valida** per Summoner’s Rift: build casuali, niente roba impossibile.  
Tema spaziale, semplice e veloce. Perfetta da aprire al volo in champ select.

## Cosa fa
- Genera build troll **sensate** per SR (Normal Draft).
- Oggetti completi (niente componenti).
- Smite solo se **Jungle**.
- **Bot**: 7 oggetti (quest ADC), con 1 boots.
- **Mid**: può ottenere boots tier 3, altri ruoli solo boots normali.
- Dati e icone **locali** (niente API live, zero blocchi).

## Uso rapido (GitHub Pages)
1. Fai push del repo su GitHub.
2. Vai su `Settings` → `Pages`.
3. Imposta `Deploy from a branch`.
4. Seleziona branch `main` e folder `/ (root)`.
5. Attendi qualche minuto e apri il sito.

URL tipico:
```
https://chillingcosmic.github.io/cosmictrollingbuilds/
```

## Uso locale
Se apri `index.html` via file, alcuni browser bloccano `fetch`.  
Consiglio: usa un server locale (es. XAMPP).

Esempio con XAMPP:
1. Copia la repo in `C:\xampp\htdocs\cosmictrollingbuilds`.
2. Apri:
```
http://localhost/cosmictrollingbuilds/index.html
```

## Struttura progetto
- `index.html`: app principale.
- `data/`: `items.json`, `champions.json`, `summoners.json`.
- `assets/`: `items/`, `champions/`, `summoners/`.
- `scripts/`: script PowerShell per aggiornare dati e icone.

## Aggiornare i dati (opzionale)
Esegui dalla root del repo:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\download_items.ps1 -Locale it_IT
powershell -ExecutionPolicy Bypass -File .\scripts\download_champions.ps1 -Locale it_IT
powershell -ExecutionPolicy Bypass -File .\scripts\download_summoners.ps1 -Locale it_IT
```

Locale disponibili in EUW (esempi): `it_IT`, `en_GB`, `fr_FR`, `de_DE`, `es_ES`.

## Disclaimer
League of Legends è un marchio di Riot Games.  
Questo progetto è fan-made e **non** è affiliato a Riot.
