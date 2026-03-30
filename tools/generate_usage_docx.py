import os
import zipfile
from datetime import datetime
from xml.sax.saxutils import escape


def p(
    text: str,
    *,
    bold: bool = False,
    color: str | None = None,
    size_half_points: int | None = None,
    align: str = "left",
    shading: str | None = None,
) -> str:
    ppr = []
    if align != "left":
        ppr.append(f'<w:jc w:val="{align}"/>')
    if shading:
        ppr.append(f'<w:shd w:val="clear" w:fill="{shading}"/>')
    ppr_xml = f"<w:pPr>{''.join(ppr)}</w:pPr>" if ppr else ""

    rpr = []
    if bold:
        rpr.append("<w:b/>")
    if color:
        rpr.append(f'<w:color w:val="{color}"/>')
    if size_half_points:
        rpr.append(f'<w:sz w:val="{size_half_points}"/>')
    rpr_xml = f"<w:rPr>{''.join(rpr)}</w:rPr>" if rpr else ""

    return (
        "<w:p>"
        + ppr_xml
        + "<w:r>"
        + rpr_xml
        + f'<w:t xml:space="preserve">{escape(text)}</w:t>'
        + "</w:r></w:p>"
    )


def heading(title: str) -> str:
    return p(title, bold=True, color="1F4E78", size_half_points=32, shading="E8F3FF")


def subheading(title: str) -> str:
    return p(title, bold=True, color="2E75B6", size_half_points=26)


def bullet(text: str) -> str:
    return p(f"• {text}", size_half_points=22)


def spacer() -> str:
    return p("")


def screenshot_placeholder(title: str) -> str:
    rows = [
        p(f"[ESPACE SCREENSHOT] {title}", bold=True, color="404040", align="center", shading="F2F2F2"),
        p("Insérer une capture d'écran ici", align="center", shading="F2F2F2"),
        p("", shading="F2F2F2"),
        p("", shading="F2F2F2"),
        p("", shading="F2F2F2"),
    ]
    return "".join(rows)


def build_document(body: str) -> str:
    body += (
        '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1440" w:right="1200" w:bottom="1440" w:left="1200" '
        'w:header="708" w:footer="708" w:gutter="0"/></w:sectPr>'
    )

    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" '
        'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
        'xmlns:o="urn:schemas-microsoft-com:office:office" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
        'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" '
        'xmlns:v="urn:schemas-microsoft-com:vml" '
        'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
        'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
        'xmlns:w10="urn:schemas-microsoft-com:office:word" '
        'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
        'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" '
        'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" '
        'xmlns:wne="http://schemas.microsoft.com/office/2006/wordml" '
        'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" '
        'mc:Ignorable="w14 wp14"><w:body>'
        + body
        + "</w:body></w:document>"
    )


def main() -> None:
    body = ""
    body += p("QRnutrition", bold=True, color="1F4E78", size_half_points=46, align="center")
    body += p("Guide d'utilisation", bold=True, color="2E75B6", size_half_points=34, align="center")
    body += p("Version: 2026", align="center", color="5B5B5B")
    body += spacer()

    body += heading("1) Objectif")
    body += p(
        "QRnutrition permet de scanner des produits alimentaires, consulter les informations nutritionnelles, "
        "suivre les repas consommés et visualiser un dashboard quotidien/hebdomadaire."
    )
    body += spacer()

    body += heading("2) Connexion et compte utilisateur")
    body += bullet("Créer un compte via Email/Password ou se connecter avec Google.")
    body += bullet("Un nouveau compte obtient le rôle user par défaut.")
    body += bullet("Les rôles admin/super_admin sont attribués manuellement dans Firestore.")
    body += screenshot_placeholder("Écran de connexion")
    body += spacer()

    body += heading("3) Navigation")
    body += bullet("Scanner")
    body += bullet("Recherche produit")
    body += bullet("Historique")
    body += bullet("Dashboard nutritionnel")
    body += bullet("Profil")
    body += spacer()
    body += subheading("Pages par rôle")
    body += bullet("Rôle user: Accueil, Scanner, Recherche, Fiche produit, Historique, Dashboard, Profil.")
    body += bullet("Rôle admin: toutes les pages user + Admin Home, Produits (liste/ajout/modification), Statistiques, Logs.")
    body += bullet("Rôle super_admin: toutes les pages admin + Super Admin Home, Gestion des admins, Paramètres globaux, Logs système.")
    body += screenshot_placeholder("Accueil utilisateur")
    body += spacer()

    body += heading("4) Scanner un produit")
    body += bullet("Scanner un code-barres via caméra ou importer une image.")
    body += bullet("Recherche locale Firestore, puis fallback OpenFoodFacts.")
    body += bullet("Affiche image, nutriments, Nutri-Score, NOVA, Éco-score (si disponibles).")
    body += screenshot_placeholder("Résultat du scan")
    body += spacer()

    body += heading("5) Fiche produit")
    body += bullet("Image du produit")
    body += bullet("Calories, protéines, glucides, lipides")
    body += bullet("Tableau nutritionnel")
    body += bullet("Ingrédients, allergènes, Nutri-Score, NOVA, Éco-score")
    body += screenshot_placeholder("Fiche produit")
    body += spacer()

    body += heading("6) Repas (ajout / modification / suppression)")
    body += bullet("Ajouter depuis la fiche produit: bouton J'ai mangé ce produit.")
    body += bullet("Ajouter depuis Dashboard (Jour): bouton Ajouter (repas manuel).")
    body += bullet("Modifier dans Dashboard (Jour): disponible pour les repas manuels.")
    body += bullet("Supprimer depuis Dashboard (Jour) ou Historique.")
    body += screenshot_placeholder("Dashboard - gestion des repas")
    body += spacer()

    body += heading("7) Dashboard nutritionnel")
    body += subheading("Mode Jour")
    body += bullet("Progression calories")
    body += bullet("Macros P/G/L")
    body += bullet("Liste des repas du jour avec actions CRUD")
    body += bullet("Navigation jour précédent / suivant")
    body += subheading("Mode Semaine")
    body += bullet("Totaux hebdomadaires calories et macros")
    body += screenshot_placeholder("Dashboard Jour/Semaine")
    body += spacer()

    body += heading("8) Historique")
    body += bullet("Liste des repas/scans enregistrés.")
    body += bullet("Détails par élément + suppression.")
    body += screenshot_placeholder("Historique")
    body += spacer()

    body += heading("9) Recherche produit")
    body += bullet("Recherche par nom ou code-barres.")
    body += bullet("Source locale Firestore puis fallback OpenFoodFacts.")
    body += screenshot_placeholder("Recherche produit")
    body += spacer()

    body += heading("10) Données Firestore")
    body += bullet("users/{uid}")
    body += bullet("users/{uid}/scan_history/{scanId}")
    body += bullet("scans/{scanId}")
    body += bullet("products/{productId} (si catalogue local)")
    body += spacer()

    body += heading("11) Dépannage rapide")
    body += bullet("Produit introuvable: vérifier code-barres + internet.")
    body += bullet("Permission caméra refusée: activer la permission dans les réglages.")
    body += bullet("Erreur Firebase: vérifier flutterfire + règles Firestore.")
    body += spacer()

    body += heading("12) Branding")
    body += bullet("Nom: QRnutrition")
    body += bullet("Icône: icon.png (générée Android/iOS)")

    document_xml = build_document(body)
    content_types_xml = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
        '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
        '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
        "</Types>"
    )
    rels_xml = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
        '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
        "</Relationships>"
    )
    core_xml = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" '
        'xmlns:dcterms="http://purl.org/dc/terms/" '
        'xmlns:dcmitype="http://purl.org/dc/dcmitype/" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        "<dc:title>Guide d'utilisation - QRnutrition</dc:title>"
        "<dc:creator>QRnutrition</dc:creator>"
        "<cp:lastModifiedBy>QRnutrition</cp:lastModifiedBy>"
        "</cp:coreProperties>"
    )
    app_xml = (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
        'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
        "<Application>Microsoft Office Word</Application>"
        "</Properties>"
    )

    output = "Guide_Utilisation.docx"
    try:
        with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("[Content_Types].xml", content_types_xml)
            zf.writestr("_rels/.rels", rels_xml)
            zf.writestr("word/document.xml", document_xml)
            zf.writestr("docProps/core.xml", core_xml)
            zf.writestr("docProps/app.xml", app_xml)
        print(f"Created {os.path.abspath(output)}")
    except PermissionError:
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        alt = f"Guide_Utilisation_updated_{stamp}.docx"
        with zipfile.ZipFile(alt, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("[Content_Types].xml", content_types_xml)
            zf.writestr("_rels/.rels", rels_xml)
            zf.writestr("word/document.xml", document_xml)
            zf.writestr("docProps/core.xml", core_xml)
            zf.writestr("docProps/app.xml", app_xml)
        print(
            "Guide_Utilisation.docx is locked. "
            f"Created {os.path.abspath(alt)} instead."
        )


if __name__ == "__main__":
    main()

