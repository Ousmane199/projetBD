
  CREATE OR REPLACE FORCE EDITIONABLE VIEW PRODUCTION_MENSUELLE_USINE_NOM ("NOMU", "MOIS", "ANNEE", "TOTAL_PRODUCTION") AS 
  SELECT
    u.NomU,
    TO_NUMBER(TO_CHAR(f.DateFab, 'MM')) AS Mois,
    TO_CHAR(f.DateFab, 'YYYY') AS Annee,
    SUM(f.Qte_Fab) AS Total_Production
FROM FABRIQUER f, USINES u
WHERE f.CodeU = u.CodeU
GROUP BY
    u.NomU,
    TO_NUMBER(TO_CHAR(f.DateFab, 'MM')),
    TO_CHAR(f.DateFab, 'YYYY');






  CREATE OR REPLACE FORCE EDITIONABLE VIEW TAUX_PRODUCTION ("CODEU", "NOMU", "CODEP", "NOMP", "ANNEE", "MOIS", "QTE_PRODUITE", "QTE_PREVUE", "TAUX_PRODUCTION") AS 
  SELECT
    U.CodeU,
    U.NomU,
    P.CodeP,
    P.NomP,
    EXTRACT(YEAR FROM F.DateFab) AS Annee,
    EXTRACT(MONTH FROM F.DateFab) AS Mois,
    SUM(F.Qte_Fab) AS QTE_PRODUITE,
    SUM(F.Qte_Fab) AS QTE_PREVUE,
    CASE 
        WHEN SUM(F.Qte_Fab) = 0 THEN 0
        ELSE ROUND(SUM(F.Qte_Fab) / SUM(F.Qte_Fab) * 100, 2)
    END AS TAUX_PRODUCTION
FROM USINES U
JOIN DEPARTEMENTS D ON U.CodeU = D.CodeU
JOIN FABRIQUER F ON D.CodeD = F.CodeU  
JOIN PRODUITS P ON F.CodeP = P.CodeP
GROUP BY U.CodeU, U.NomU, P.CodeP, P.NomP, EXTRACT(YEAR FROM F.DateFab), EXTRACT(MONTH FROM F.DateFab);






  CREATE OR REPLACE FORCE EDITIONABLE VIEW TAUX_VENTE ("CODEP", "NOMP", "CODEPV", "NOMPV", "MOIS", "ANNEE", "QTE_VENDUE", "QTE_PRODUITE", "TAUX_VENTE") AS 
  SELECT
    P.CodeP,
    P.NomP,
    PV.CodePV,
    PV.NomPV,
    V.Mois AS Mois,
    V.Annee AS Annee,
    SUM(V.Qte_Vendue) AS QTE_VENDUE,
    SUM(F.Qte_Fab) AS QTE_PRODUITE,
    CASE
        WHEN SUM(F.Qte_Fab) IS NULL OR SUM(F.Qte_Fab) = 0 THEN 0
        ELSE ROUND(SUM(V.Qte_Vendue) / SUM(F.Qte_Fab) * 100, 2)
    END AS TAUX_VENTE
FROM VENDRE V
JOIN PRODUITS P ON V.CodeP = P.CodeP
JOIN POINTS_DE_VENTE PV ON V.CodePV = PV.CodePV
LEFT JOIN FABRIQUER F
    ON V.CodeP = F.CodeP
    AND EXTRACT(YEAR FROM F.DateFab) = V.Annee
    AND EXTRACT(MONTH FROM F.DateFab) = V.Mois
GROUP BY P.CodeP, P.NomP, PV.CodePV, PV.NomPV, V.Mois, V.Annee;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW USINE_PLUS_RENTABLE ("ANNEE", "MOIS", "CODEU", "NOMU", "VILLEU", "CA_TOTAL", "SALAIRES_TOTAL_MASSE_SALARIAL", "BENEFICE_NET", "MARGE_POURCENT") AS 
  SELECT "ANNEE","MOIS","CODEU","NOMU","VILLEU","CA_TOTAL","SALAIRES_TOTAL_MASSE_SALARIAL","BENEFICE_NET","MARGE_POURCENT" FROM (
    SELECT TO_NUMBER(TO_CHAR(fab.DateFab, 'YYYY')) AS Annee,
           TO_NUMBER(TO_CHAR(fab.DateFab, 'MM')) AS Mois,
           u.CodeU,
           u.NomU,
           u.VilleU,
           SUM(fab.Qte_Fab * f.PrixUnitP) AS CA_Total,
           SUM(p1.FixeMensuelE + p1.IndiceSalE * tu.NbHeures_U) AS Salaires_Total_masse_salarial,
           SUM(fab.Qte_Fab * f.PrixUnitP) - SUM(p1.FixeMensuelE + p1.IndiceSalE * tu.NbHeures_U) AS Benefice_Net,
           ROUND((SUM(fab.Qte_Fab * f.PrixUnitP) - SUM(p1.FixeMensuelE + p1.IndiceSalE * tu.NbHeures_U)) /
                 SUM(fab.Qte_Fab * f.PrixUnitP) * 100, 2) AS Marge_Pourcent
    FROM USINES u,
         DEPARTEMENTS d,
         TRAVAILLER_USINE tu,
         FABRIQUER fab,
         FACTURER f,
         PAYER1 p1
    WHERE u.CodeU = d.CodeU
      AND d.CodeD = tu.CodeD
      AND u.CodeU = fab.CodeU
      AND fab.CodeP = f.CodeP
      AND tu.CodeE = p1.CodeE
      AND TO_NUMBER(TO_CHAR(fab.DateFab, 'MM')) = f.Mois
      AND TO_NUMBER(TO_CHAR(fab.DateFab, 'YYYY')) = f.Annee
      AND tu.Annee = p1.Annee
      AND tu.Mois = f.Mois
    GROUP BY TO_NUMBER(TO_CHAR(fab.DateFab, 'YYYY')),
             TO_NUMBER(TO_CHAR(fab.DateFab, 'MM')),
             u.CodeU,
             u.NomU,
             u.VilleU
    HAVING SUM(fab.Qte_Fab * f.PrixUnitP) > SUM(p1.FixeMensuelE + p1.IndiceSalE * tu.NbHeures_U)
    ORDER BY TO_NUMBER(TO_CHAR(fab.DateFab, 'YYYY')) DESC,
             TO_NUMBER(TO_CHAR(fab.DateFab, 'MM')) DESC,
             Benefice_Net DESC
)
WHERE ROWNUM <= 5;



  CREATE OR REPLACE FORCE EDITIONABLE VIEW CHIFFRESCLESSOCIETE_MG ("CODEG", "NOMG", "NBPRODUITSPARGAMME", "NBTOTALGAMMES", "NBTOTALPRODUITS", "NBTOTALUSINES", "NBTOTALPOINTSDEVENTE") AS 
  SELECT G.CodeG, G.NomG, COUNT(DISTINCT P.CodeP) AS NbProduitsParGamme,
    (SELECT COUNT(DISTINCT CodeG) FROM GAMME) AS NbTotalGammes,
    (SELECT COUNT(DISTINCT CodeP) FROM PRODUITS) AS NbTotalProduits,
    (SELECT COUNT(DISTINCT CodeU) FROM USINES) AS NbTotalUsines,
    (SELECT COUNT(DISTINCT CodePV) FROM POINTS_DE_VENTE) AS NbTotalPointsDeVente
FROM GAMME G, PRODUITS P
WHERE G.CodeG = P.CodeG(+)
GROUP BY G.CodeG, G.NomG;





  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_CA ("CODEP", "NOMP", "NOMG", "CODEPV", "NOMPV", "VILLEPV", "MOIS", "ANNEE", "QTE_VENDUE", "PRIXUNITP", "CHIFFREAFFAIRES") AS 
  SELECT
    v.CodeP,
    p.NomP,
    g.NomG,
    v.CodePV,
    pv.NomPV,
    pv.VillePV,
    v.Mois,
    v.Annee,
    v.Qte_Vendue,
    f.PrixUnitP,
    (v.Qte_Vendue * f.PrixUnitP) AS ChiffreAffaires
FROM VENDRE v, FACTURER f , PRODUITS p , GAMME g, POINTS_DE_VENTE pv
WHERE v.CodeP = f.CodeP AND v.Mois = f.Mois AND v.Annee = f.Annee
AND v.CodeP = p.CodeP
AND p.CodeG = g.CodeG
AND v.CodePV = pv.CodePV;




  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_CA_MENSUEL ("ANNEE", "MOIS", "CA_MENSUEL") AS 
  SELECT annee, Mois, SUM(ChiffreAffaires) AS CA_Mensuel
FROM V_CA
GROUP BY Annee, Mois
ORDER BY Annee, Mois;




  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_CA_PAR_PV ("NOMPV", "CA_POINTDEVENTE") AS 
  SELECT NomPV, SUM(ChiffreAffaires) AS CA_PointDeVente
FROM V_CA
GROUP BY NomPV
ORDER BY CA_PointDeVente DESC;




  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_CA_PAR_VILLE ("VILLEPV", "CA_VILLE") AS 
  SELECT VillePV, SUM(ChiffreAffaires) AS CA_Ville
FROM V_CA
GROUP BY VillePV
ORDER BY CA_Ville DESC;




  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_FACT_EM_SALAIRES ("MOIS", "ANNEE", "CODEE", "NOME", "PRENOME", "VILLEPERSE", "VILLEPROE", "NOMD", "NOMU", "VILLEU", "SALAIRE_FIXE", "SALAIRE_VARIABLE", "SALAIRE_RETROCESSION", "SALAIRE_TOTAL") AS 
  SELECT
    tpv.Mois,                                    
    tpv.Annee,                                   
    E.CODEE,                                     
    E.NOME,                                      
    E.PRENOME,                                   
    e.VILLEPERSE,                                
    e.VILLEPROE,                                 
    d.NOMD,                                      
    u.NOMU,                                      
    u.VILLEU,                                    
    COALESCE(P1.FIXEMENSUELE, 0) AS Salaire_Fixe, 
    COALESCE(P1.IndiceSalE * tpv.NbHeures_PV, 0) AS Salaire_Variable, 
    COALESCE((
                 SELECT SUM(F.PrixUnitP * V.Qte_Vendue * P2.IndiceRetrocessionG)
                 FROM VENDRE V
                          JOIN FACTURER F ON F.CodeP = V.CodeP AND F.Mois = V.Mois AND F.Annee = V.Annee
                          JOIN PRODUITS p ON p.CodeP = V.CodeP
                          JOIN RESPONSABLE R ON R.CodeE = E.CodeE AND R.Annee = V.Annee
                          JOIN PAYER2 P2 ON P2.CodeG = R.CodeG AND P2.Annee = V.Annee
                 WHERE V.CodeE = E.CodeE
                   AND V.Mois = tpv.Mois
                   AND V.Annee = tpv.Annee
                   AND V.CodePV = tpv.CodePV
             ), 0) AS Salaire_Retrocession, 
    COALESCE(P1.FIXEMENSUELE + P1.IndiceSalE * tpv.NbHeures_PV, 0) +
    COALESCE((
                 SELECT SUM(F.PrixUnitP * V.Qte_Vendue * P2.IndiceRetrocessionG)
                 FROM VENDRE V
                          JOIN FACTURER F ON F.CodeP = V.CodeP AND F.Mois = V.Mois AND F.Annee = V.Annee
                          JOIN PRODUITS p ON p.CodeP = V.CodeP
                          JOIN RESPONSABLE R ON R.CodeE = E.CodeE AND R.Annee = V.Annee
                          JOIN PAYER2 P2 ON P2.CodeG = R.CodeG AND P2.Annee = V.Annee
                 WHERE V.CodeE = E.CodeE
                   AND V.Mois = tpv.Mois
                   AND V.Annee = tpv.Annee
                   AND V.CodePV = tpv.CodePV
             ), 0) AS Salaire_Total 
FROM EMPLOYES E
         JOIN TRAVAILLER_PT_VENTE tpv ON tpv.CodeE = E.CodeE
         LEFT JOIN PAYER1 P1 ON P1.CodeE = E.CodeE AND P1.Annee = tpv.Annee
         LEFT JOIN TRAVAILLER_USINE tu ON tu.CodeE = E.CodeE AND tu.Mois = tpv.Mois AND tu.Annee = tpv.Annee
         LEFT JOIN DEPARTEMENTS D ON D.CodeD = tu.CodeD
         LEFT JOIN USINES U ON U.CodeU = D.CodeU
GROUP BY
    E.CODEE, E.NOME, E.PRENOME, e.VILLEPERSE, e.VILLEPROE,
    D.CODED, D.NOMD, U.CODEU, U.NOMU, u.VILLEU,
    tpv.Mois, tpv.Annee, tpv.CodePV, tpv.NbHeures_PV,
    P1.FIXEMENSUELE, P1.IndiceSalE;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_PART_VENTES_PV ("CODEPV", "NOMPV", "VILLEPV", "TYPEPV", "MOIS", "ANNEE", "CHIFFRE_DAFFAIRES_TOTAL") AS 
  SELECT
    vca.CODEPV,
    vca.NOMPV,
    vca.VILLEPV,
    pv.TYPEPV,
    vca.MOIS,
    vca.ANNEE,
    SUM(vca.CHIFFREAFFAIRES) AS CHIFFRE_DAFFAIRES_TOTAL
FROM V_CA vca
JOIN POINTS_DE_VENTE pv ON vca.CODEPV = pv.CODEPV
GROUP BY
    vca.CODEPV,
    vca.NOMPV,
    vca.VILLEPV,
    pv.TYPEPV,
    vca.MOIS,
    vca.ANNEE;





  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_PRIX_MOYEN_GAMME ("NOMG", "PRIX_MOYEN") AS 
  SELECT NomG, AVG(PrixUnitP) AS Prix_Moyen
FROM V_CA
GROUP BY NomG;





  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_TOP5_PRODUITS ("NOMP", "CA_PRODUIT") AS 
  SELECT NomP, SUM(ChiffreAffaires) AS CA_Produit
FROM V_CA
GROUP BY NomP
ORDER BY CA_Produit DESC
FETCH FIRST 5 ROWS ONLY;





  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_VOLUME_GAMME ("NOMG", "VOLUMETOTAL") AS 
  SELECT NomG, SUM(Qte_Vendue) AS VolumeTotal
FROM V_CA
GROUP BY NomG
ORDER BY VolumeTotal DESC;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW VENTES_PAR_PV ("CODEPV", "NOMPV", "ANNEE", "MOIS", "CA_VENTES", "TX_CROISSANCE") AS 
  WITH CA_MENSUEL AS (
        SELECT
            PV.CodePV,
            PV.NomPV,
            V.Annee,
            V.Mois,
            SUM(V.Qte_Vendue * F.PrixUnitP) AS CA_VENTES
        FROM POINTS_DE_VENTE PV
        JOIN VENDRE V ON PV.CodePV = V.CodePV
        JOIN FACTURER F ON V.CodeP = F.CodeP AND V.Mois = F.Mois AND V.Annee = F.Annee
        GROUP BY
            PV.CodePV,
            PV.NomPV,
            V.Annee,
            V.Mois
    ),
    CA_AVEC_PRECEDENT AS (
        SELECT
            CODEPV,
            NOMPV,
            ANNEE,
            MOIS,
            CA_VENTES,
            LAG(CA_VENTES) OVER (PARTITION BY CODEPV ORDER BY ANNEE, MOIS) AS CA_PRECEDENT
        FROM CA_MENSUEL
    )
    SELECT
        CODEPV,
        NOMPV,
        ANNEE,
        MOIS,
        CA_VENTES,
        ROUND(
            CASE
                WHEN CA_PRECEDENT IS NULL OR CA_PRECEDENT = 0 THEN NULL
                WHEN CA_PRECEDENT < 500 THEN NULL  -- Ignore les CA initiaux trop faibles
                ELSE LEAST(GREATEST(((CA_VENTES - CA_PRECEDENT) / CA_PRECEDENT) * 100, -100), 100)
            END, 2
        ) AS TX_CROISSANCE
    FROM CA_AVEC_PRECEDENT
    ORDER BY CODEPV, ANNEE, MOIS;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW VUE_GENERALE_SYNTHESE_TEMPORELLE ("ANNEE", "MOIS", "NB_USINES", "NB_EMPLOYES", "NB_DEPARTEMENTS", "NB_POINTS_VENTE", "NB_VILLES_PV", "NB_PRODUITS", "NB_GAMMES", "CA_MENSUEL") AS 
  SELECT
    V.Annee,
    V.Mois,

    (SELECT COUNT(DISTINCT CodeU) FROM USINES) AS Nb_Usines,
    (SELECT COUNT(DISTINCT CodeE) FROM EMPLOYES) AS Nb_Employes,
    (SELECT COUNT(DISTINCT CodeD) FROM DEPARTEMENTS) AS Nb_Departements,
    (SELECT COUNT(DISTINCT CodePV) FROM POINTS_DE_VENTE) AS Nb_Points_Vente,
    (SELECT COUNT(DISTINCT VillePV) FROM POINTS_DE_VENTE) AS Nb_Villes_PV,
    (SELECT COUNT(DISTINCT CodeP) FROM PRODUITS) AS Nb_Produits,
    (SELECT COUNT(DISTINCT CodeG) FROM GAMME) AS Nb_Gammes,

    SUM(V.Qte_Vendue * F.PrixUnitP) AS CA_Mensuel
FROM VENDRE V, FACTURER F 
WHERE V.CodeP = F.CodeP 
AND V.Annee = F.Annee
GROUP BY V.Annee, V.Mois
ORDER BY V.Annee, V.Mois;








  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_COUT_SALARIAL ("COUT_SALARIAL_ANNUEL") AS 
  SELECT
  ROUND(SUM(p.FixeMensuelE * p.IndiceSalE * 12), 2) AS cout_salarial_annuel
FROM PAYER1 p;







  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_EMPLOYES_QUALIFIES ("TYPE_QUALIFICATION", "NB_EMPLOYES") AS 
  SELECT
  q.NomQ AS type_qualification,
  COUNT(DISTINCT po.CodeE) AS nb_employes
FROM POSSEDER po
JOIN QUALIFICATIONS q ON q.CodeQ = po.CodeQ
GROUP BY q.NomQ
ORDER BY nb_employes DESC;





  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_EMPLOYES_VILLES ("CODEE", "NOME", "PRENOME", "VILLEPROE", "NOMD") AS 
  SELECT E.CODEE, E.NOME, E.PRENOME, E.VILLEPROE
, D.NOMD
FROM EMPLOYES E, TRAVAILLER_USINE TU, DEPARTEMENTS D
WHERE E.CODEE = TU.CODEE
AND TU.CODED = D.CODED;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_EVOLUTION_SALAIRE_MOYEN ("ANNEE", "SALAIRE_MOYEN") AS 
  SELECT
  p.Annee,
  ROUND(AVG(p.FixeMensuelE * p.IndiceSalE), 2) AS salaire_moyen
FROM PAYER1 p
GROUP BY p.Annee
ORDER BY p.Annee;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_HEURES_PAR_MOIS ("MOIS", "ANNEE", "CODEE", "NOME", "PRENOME", "NOMD", "NOMU", "NBHEURES_PV", "NBHEURES_U") AS 
  select tpv.Mois,
       tpv.Annee,
       E.CODEE,
       E.NOME,
       E.PRENOME,
       D.NOMD,
       U.NOMU
        ,coalesce(sum(NBHEURES_PV), 0) as NBHEURES_PV
        ,coalesce(sum(NBHEURES_U), 0) as NBHEURES_U
from EMPLOYES e
         join TRAVAILLER_PT_VENTE tpv on e.CODEE = tpv.CODEE
         left join TRAVAILLER_USINE tu on e.CODEE = tu.CODEE
    AND tu.Mois = tpv.Mois
    AND tu.Annee = tpv.Annee
         left join DEPARTEMENTS d on tu.CODED = d.CODED
         left join USINES u on d.CODEU = u.CODEU
group by tpv.Mois, tpv.Annee, E.CODEE, E.NOME, e.PRENOME, d.NOMD, u.NOMU;






  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_HEURES_PRODUITES ("HEURES_PRODUITES") AS 
  SELECT
  SUM(tu.NbHeures_U) + SUM(tp.NbHeures_PV) AS heures_produites
FROM TRAVAILLER_USINE tu
JOIN TRAVAILLER_PT_VENTE tp ON tu.CodeE = tp.CodeE;







  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MOY_HEURES_PAR_PV ("MOY_HEURES_PAR_PV") AS 
  SELECT
  ROUND(AVG(NbHeures_PV), 2) AS moy_heures_par_pv
FROM TRAVAILLER_PT_VENTE;




