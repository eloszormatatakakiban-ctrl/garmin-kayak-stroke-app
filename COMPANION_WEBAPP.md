# Kayak Stroke – futtatás és Render telepítés

A Garmin Connect IQ óra-app továbbra is Monkey C-ben készül; ezt nem a Render futtatja. Ez a repó külön webes próba-dashboardot tartalmaz, Python + Flask szerverrel, a spanyol kártyás projekthez hasonló egyszerű szerveres megközelítéssel.

## Renderen telepítés

A repo gyökerében már van `render.yaml`, `requirements.txt`, `Procfile` és `app.py`.

1. GitHubon ellenőrizd, hogy ezek a fájlok a `main` ágon vannak.
2. Renderben válaszd a **New + → Blueprint** lehetőséget, majd kapcsold össze a GitHubot és válaszd ki az `eloszormatatakakiban-ctrl/garmin-kayak-stroke-app` repót.
3. A Render olvassa a gyökérben lévő `render.yaml` fájlt. Ellenőrizd a szolgáltatás beállításait, majd kattints az **Apply** gombra.
4. A build parancs: `pip install -r requirements.txt`; az indítási parancs: `gunicorn app:app`.
5. A deploy után nyisd meg a Render által adott `https://...onrender.com` címet. A health ellenőrzés: `https://...onrender.com/api/health`.

Ha kézzel hozod létre, válaszd a **New + → Web Service** menüpontot, majd ugyanezt a GitHub repót. Build Command: `pip install -r requirements.txt`. Start Command: `gunicorn app:app`. Root Directory üresen hagyható (`.`). Python runtime-ot válassz, ha Render rákérdez. Ne állítsd Node.js runtime-ra.

A csomagok és ingyenes tier korlátai idővel változhatnak; a Render létrehozáskor megjelenő díjazását ellenőrizd. Az ingyenes szolgáltatás inaktivitás után alvó állapotba kerülhet.

## Helyi teszt

Szükséges a Python 3.10+.

```bash
python -m venv .venv
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# macOS/Linux:
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

Böngésző: `http://localhost:10000`; ellenőrzés: `http://localhost:10000/api/health`.

## Garmin óra-app

A `source/` Monkey C kódot a Garmin Connect IQ SDK Managerrel és VS Code Monkey C bővítménnyel buildeld/szimuláld. A Forerunner 970 van megadva céltermékként a `manifest.xml`-ben. Órára telepítéshez kövesd a Garmin Connect IQ fejlesztői tesztelési útmutatóját; nyilvános Store-publikáláshoz exportálj `.iq` csomagot, és küldd be Garmin felülvizsgálatra.

## Korlát

A dashboard próbaűrlapja a `/api/session` végpontnak küld adatot, amely válaszban visszaadja azt; tartós adatbázis nincs beállítva. A Garmin óra és a weboldal jelenleg nincs automatikusan összekötve. Ez külön fejlesztési feladat.
