import os
import shutil
import subprocess
import sys

# Konfigurasjon
RepoPath = r"C:\Users\bgron\Dropbox\HUGO\Sites\nutanix-dump"
DocsPath = os.path.join(RepoPath, "docs")
# Hvis du vil ha custom domene senere, skriv det her (f.eks. "tech.bengt.no"). Ellers la den være None.
CustomDomain = None 

def build_site():
    print(f"🚀 Starter Windows Build for Nutanix Dump...")
    
    # 1. Rens opp gammel docs-mappe
    if os.path.exists(DocsPath):
        try:
            shutil.rmtree(DocsPath)
            print("🧹 Gammel /docs mappe slettet.")
        except Exception as e:
            print(f"⚠️ Kunne ikke slette docs: {e}")

    # 2. Kjør Hugo
    # På Windows må vi noen ganger spesifisere 'shell=True' hvis hugo ikke er i direkte PATH
    try:
        subprocess.run(["hugo"], cwd=RepoPath, check=True, shell=True)
        print("✅ Hugo build fullført. Filene ligger i /docs")
    except subprocess.CalledProcessError:
        print("❌ Feil: Hugo krasjet. Sjekk config.toml.")
        sys.exit(1)

    # 3. CNAME for Custom Domain (GitHub Pages krever filen 'CNAME' i roten av publiseringsmappen)
    if CustomDomain:
        cname_file = os.path.join(DocsPath, "CNAME")
        with open(cname_file, "w") as f:
            f.write(CustomDomain)
        print(f"🌐 CNAME fil opprettet for: {CustomDomain}")

    # 4. Git instruksjoner
    print("\n--- Neste steg i terminalen ---")
    print("git add .")
    print("git commit -m \"New build\"")
    print("git push -u origin main")

if __name__ == "__main__":
    build_site()