Neuerwerbungsliste Sammlung Deutscher Drucke an der Herzog August Bibliothek
=

Installation
--

Kopie dieses Repositories inklusive des Submoduls.

```
git clone --recursive https://github.com/dmj/xproc-nel.git
```

Systemvoraussetzungen
--

- XProc 1.0 Prozessor mit Apache FOP-Verbindung (getestet mit XML Calabash)
Beide Programme sind in Oxygen (Version 20.1) enthalten. Vorgehen: Man kopiert dieses Repositorium in ein Verzeichnis (das eingebundene Repositorium fo2pdf muss ggf. gesondert heruntergeladen werden). Man ruft in Oxygen die Datei nel.xpl auf. Dann erzeugt man ein neues Transformationsszenario (Str + Umschalt + C, Schaltfläche "Neu") und wählt "XProc transformation". Im Reiter "Optionen" definiert man die Werte für nea nel und label wie unten beschrieben. Dann das Transformationsszenario speichern und ausführen.

System der Neuerwerbungslisten
--

Für die Aufnahme eines Titels in die Neuerwerbungsliste SDD wird auf
Exemplarebene in der Kategorie 4880 ein Eintrag vorgenommen, aus dem
Jahr und Monat der Neuerwerbung sowie die Zuordnung zur SDD entnommen
werden kann.

Beispiel: Neuerwerbung der Sammlung Deutscher Drucke aus August 2019.

```
4880 2019-08$asdd 
```

Die so gekennzeichneten Titel können über den Suchindex NEL (IKT 8004,
Neuerwerbungslisten) in Kombination mit dem Index NEA (IKT 8005,
Neuerwerbungslisten-Abteilung) zum Beispiel über die
[SRU-Schnittstelle](http://sru.gbv.de/opac-de-23) abgefragt werden.

```
GET http://sru.gbv.de/opac-de-23?operation=searchRetrieve&query=pica.nel%3D2019-08+and+pica.nea%3Dsdd

<zs:searchRetrieveResponse>
  <zs:numberOfRecords>18</zs:numberOfRecords>
  <zs:echoedSearchRetrieveRequest>
    <zs:version>2.0</zs:version>
    <zs:query>pica.nel=2019-08 and pica.nea=sdd</zs:query>
    <zs:recordXMLEscaping>xml</zs:recordXMLEscaping>
  </zs:echoedSearchRetrieveRequest>
  <zs:resultCountPrecision>exact</zs:resultCountPrecision>
</zs:searchRetrieveResponse>

```

Neuerwerbungsliste mittels XProc
--

Die XProc-Pipeline ```nel.xpl``` verwendet die SRU-Schnittstelle des
k10plus um die Titelliste als HTML und als PDF zu generieren.

Der Pipeline müssen folgende Parameter übergeben werden:

- **nea** "Abteilungskennung", hier immer ```sdd```
- **nel** Suchstring für Zeitraum der Neuerwerbung
- **label** Natürlichsprachige Angabe des Listenzeitraums

```
calabash nel.xpl nea=sdd nel="2019-0[12345678]*" label="Januar bis August 2019"
```

Sie erzeugt die Dateien ```sddlist.htm``` und ```sddlist.pdf``` im
Verzeichnis ```public```.

Diese Dateien können dann z.B. mittels ftp auf
```dbs.hab.de/sddlist``` kopiert werden.

