--1
SELECT g.NomG
FROM gamme g
WHERE g.CodeG NOT IN(
  SELECT p.CodeG
  FROM produits p, vendre v, points_de_vente pv
  WHERE p.CodeP =  v.CodeP
  AND v.CodePV = pv.CodePV
  AND lower(pv.TypePV) = 'brico-express');



--2
SELECT pv.NomPV, pv.RuePV, pv.CPostalPV, pv.VillePV, COUNT(DISTINCT e.CodeE) AS  Nb_Salairiés
FROM points_de_vente pv, travailler_pt_vente tpv, employes e
WHERE pv.CodePV = tpv.CodePV(+)
AND tpv.CodeE = e.CodeE
AND pv.TypePV = 'GSB' --Grande surface breco
GROUP BY pv.NomPV, pv.RuePV, pv.CPostalPV, pv.VillePV, pv.CodePV, tpv.Mois, tpv.Annee;


SELECT pv.NomPV, pv.RuePV, pv.CPostalPV, pv.VillePV, COUNT(DISTINCT tpv.CodeE) AS  Nb_Salairiés
FROM points_de_vente pv, travailler_pt_vente tpv
WHERE pv.CodePV = tpv.CodePV(+)
AND pv.TypePV = 'GSB' --Grande surface breco
GROUP BY pv.NomPV, pv.RuePV, pv.CPostalPV, pv.VillePV, pv.CodePV, tpv.Mois, tpv.Annee;

--3

SELECT DISTINCT u.NomU, u.RueU, u.CPostalU, u.VilleU
FROM usines u, departements d, autoriser a, qualifications q
WHERE u.CodeU = d.CodeU
AND d.CodeD = a.CodeD
AND a.CodeQ = q.CodeQ
AND q.CodeQ NOT IN (
   SELECT p.CodeQ
   FROM posseder p, employes e, travailler_usine tu, departements d2
   WHERE p.CodeE = e.CodeE
   AND e.CodeE = tu.CodeE
   AND tu.CodeD = d2.CodeD
   AND d2.CodeU = u.CodeU
)
ORDER BY u.NomU;

select * from QUALIFICATIONS;
select * from AUTORISER;

insert into QUALIFICATIONS values(6,'Technicien maintenance niveau 2',15.5,3);
insert into AUTORISER values (3,6);
commit ;


--4


SELECT pv.NomPV, pv.TypePV, SUM(v.Qte_Vendue * f.PrixUnitP) as CA
FROM POINTS_DE_VENTE pv, VENDRE v, FACTURER f
WHERE v.CodePV = pv.CodePV
 AND v.CodeP = f.CodeP
 AND v.Mois  = f.Mois
 AND v.Annee = f.Annee
 AND v.Annee = 2022
 AND v.Mois = 1
GROUP BY pv.CodePV, pv.NomPV, pv.TypePV
HAVING SUM(v.Qte_Vendue * f.PrixUnitP) = (
   SELECT MAX(CA)
   FROM (
       SELECT SUM(v2.Qte_Vendue * f2.PrixUnitP) as CA
       FROM VENDRE v2, FACTURER f2
       WHERE v2.CodeP = f2.CodeP
       AND v2.Mois  = f2.Mois
       AND v2.Annee = f2.Annee
       AND v2.Annee = 2022
       AND v2.Mois  = 1
       GROUP BY v2.CodePV
   )
);


--5

SELECT DISTINCT p.NomP, f.PrixUnitP
FROM PRODUITS p, VENDRE v, FACTURER f, POINTS_DE_VENTE pv
WHERE p.CodeP = v.CodeP
  AND f.CodeP = v.CodeP
  AND f.Mois  = v.Mois
  AND f.Annee = v.Annee
  AND v.CodePV = pv.CodePV
  AND pv.CPostalPV LIKE '31%'
  AND p.CodeP NOT IN (
        SELECT fb.CodeP
        FROM FABRIQUER fb, USINES u
        WHERE fb.CodeU = u.CodeU
          AND u.CPostalU LIKE '31%'
  )
ORDER BY f.PrixUnitP DESC;


--6

SELECT tpv.Annee,
      e.NomE,
      e.PrenomE,
      SUM(p1.FixeMensuelE + p1.IndiceSalE * tpv.NbHeures_PV + f.PrixUnitP * v.Qte_Vendue * p2.IndiceRetrocessionG) AS Salaires_Mensuels
FROM EMPLOYES e,
    PAYER1 p1,
    TRAVAILLER_PT_VENTE tpv,
    FACTURER f,
    VENDRE v,
    RESPONSABLE r,
    PAYER2 p2
WHERE e.CodeE = p1.CodeE
 AND e.CodeE = tpv.CodeE
 AND e.CodeE = v.CodeE
 AND e.CodeE = r.CodeE
 AND tpv.CodePV = v.CodePV
 AND v.CodeP = f.CodeP
 AND p2.CodeG = r.CodeG
 AND v.Mois = tpv.Mois
 AND v.Mois = f.Mois
 AND v.Annee = tpv.Annee
 AND v.Annee = f.Annee
 AND p1.Annee = p2.Annee
 AND p2.Annee = r.Annee
 AND p1.Annee = tpv.Annee
 AND tpv.Annee IN (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - 1, TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - 2)
GROUP BY tpv.Annee, e.NomE, e.PrenomE, e.CodeE
ORDER BY tpv.Annee, e.NomE, e.PrenomE;




SELECT tpv.Annee, e.NomE, e.PrenomE,
      p1.FIXEMENSUELE + SUM(p1.IndiceSalE * tpv.NbHeures_Pv)+NVL(SUM(f.PrixUnitP * v.Qte_Vendue * p2.IndiceRetrocessionG),0) AS Salaires_Mensuels
FROM employes e, payer1 p1 , travailler_pt_vente tpv, facturer f, vendre v, responsable r, payer2 p2
WHERE e.CodeE = p1.CodeE
 AND e.CodeE = tpv.CodeE
 AND e.CodeE = v.CodeE
 AND e.CodeE = r.CodeE
 AND tpv.CodePV = v.CodePV
 AND v.CodeP = f.CodeP
 AND p2.CodeG = r.CodeG
 AND v.Mois = tpv.Mois
 AND v.Mois = f.Mois
 AND v.Annee = tpv.Annee
 AND v.Annee = f.Annee
 AND p1.Annee = p2.Annee
 AND p2.Annee = r.Annee
 AND p1.Annee = tpv.Annee
 AND tpv.Annee IN (to_char(sysdate, 'yyyy') - 1, to_char(sysdate, 'yyyy') - 2)
GROUP BY tpv.Annee, e.NomE, e.PrenomE, e.CodeE, p1.FIXEMENSUELE
ORDER BY tpv.Annee, e.NomE, e.PrenomE;



--7

SELECT DISTINCT U.NomU, TU.NomTU, U.VilleU, D.NomD
FROM USINES U, AVOIR_TYPE A, TYPEU TU, DEPARTEMENTS D, DEPARTEMENTS D2
WHERE U.CodeU = D.CodeU
AND U.CodeU = A.CodeU
AND A.CodeTU = TU.CodeTU
AND D.NomD = D2.NomD
AND D.CodeD <> D2.CodeD;


--8

SELECT PV.NomPV, PV.TypePV
FROM POINTS_DE_VENTE PV
WHERE NOT EXISTS (
   SELECT *
   FROM PRODUITS P, GAMME G
   WHERE P.CodeG = G.CodeG
   AND G.NomG = 'cuisine'
   AND NOT EXISTS  (
       SELECT *
       FROM VENDRE V
       WHERE V.CodePV = PV.CodePV
       AND V.CodeP = P.CodeP
       AND V.Annee = (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')))
   )
);


--9

SELECT DISTINCT E.CodeE, E.NomE, E.PrenomE
FROM EMPLOYES E, DIRIGER D, DEPARTEMENTS Dep, USINES U, RESPONSABLE R, GAMME G, PRODUITS P, FABRIQUER F
WHERE E.CodeE = D.CodeE
AND D.CodeD = Dep.CodeD
AND Dep.CodeU = U.CodeU
AND E.CodeE = R.CodeE
AND R.CodeG = G.CodeG
AND G.CodeG = P.CodeG
AND P.CodeP = F.CodeP
AND F.CodeU = U.CodeU
AND TO_CHAR(D.DateDebutDir, 'YYYY') = R.Annee;




--10

SELECT U.NomU, U.RueU, U.CPostalU, U.VilleU
FROM USINES U, FABRIQUER F
WHERE U.CodeU = F.CodeU
AND F.CodeP NOT IN (
   SELECT V.CodeP
   FROM VENDRE V
   WHERE V.Annee = TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))
)
GROUP BY U.CodeU, U.NomU, U.RueU, U.CPostalU, U.VilleU
HAVING COUNT(DISTINCT F.CodeP) = (
   SELECT MAX(NbProdFabNonVendu)
   FROM (
       SELECT U2.CodeU, COUNT(DISTINCT F2.CodeP) AS NbProdFabNonVendu
       FROM USINES U2, FABRIQUER F2
       WHERE U2.CodeU = F2.CodeU
       AND F2.CodeP NOT IN (
           SELECT V2.CodeP
           FROM VENDRE V2
           WHERE V2.Annee = TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))
       )
       GROUP BY U2.CodeU
   )
);



-- Les requetes supplementaires


-- Donner les informations personnelles (NomE, PrenomE, CodeE) des employés qui travaillent à la fois dans une usine et
-- dans un point de vente durant la même année et le même mois, mais dont la ville professionnelle est différente de celle de leurs lieux de travail.


SELECT DISTINCT e.CodeE, e.NomE, e.PrenomE
FROM EMPLOYES e, TRAVAILLER_USINE tu, TRAVAILLER_PT_VENTE tpv,
    DEPARTEMENTS d, USINES u, POINTS_DE_VENTE pv
WHERE e.CodeE = tu.CodeE
AND e.CodeE = tpv.CodeE
AND tu.Mois = tpv.Mois
AND tu.Annee = tpv.Annee
AND tu.CodeD = d.CodeD
AND d.CodeU = u.CodeU
AND tpv.CodePV = pv.CodePV
AND u.VilleU <> e.VilleProE
AND pv.VillePV <> e.VilleProE
ORDER BY  e.NomE, e.PrenomE;




-- Donner les usines dont l'ensemble des employés couvre collectivement toutes -- les qualifications exigées par leurs départements, et dont le revenu moyen -- par transaction de vente est supérieur au revenu moyen par transaction de -- l'ensemble de l'entreprise.


SELECT DISTINCT u.CodeU, u.NomU
FROM USINES u
WHERE
   --1 LES EMPLOYES QUI POSSEDE TOUTES LES QUALIFICATIONS QUE L'ENTREPRISE PROPROSE
   NOT EXISTS (
       SELECT a.CodeQ
       FROM AUTORISER a, DEPARTEMENTS d
       WHERE a.CodeD = d.CodeD
         AND d.CodeU = u.CodeU
         AND a.CodeQ NOT IN (
             -- Qualifications possédées par les employés de l'usine
             SELECT p.CodeQ
             FROM POSSEDER p
             WHERE p.CodeE IN (
                 -- Tous les employés travaillant dans l'usine
                 SELECT tu.CodeE
                 FROM TRAVAILLER_USINE tu, DEPARTEMENTS d2
                 WHERE tu.CodeD = d2.CodeD
                   AND d2.CodeU = u.CodeU
             )
         )
   )


   -- 2 Les employés de cette usine génèrent plus que la moyenne globale par transaction
   AND (
       -- Revenu moyen global
       SELECT AVG(f.PrixUnitP * v.Qte_Vendue)
       FROM VENDRE v, FACTURER f
       WHERE f.CodeP = v.CodeP
         AND f.Mois = v.Mois
         AND f.Annee = v.Annee
   ) < (
       -- Revenu moyen des employés de l'usine courante
       SELECT AVG(f2.PrixUnitP * v2.Qte_Vendue)
       FROM VENDRE v2, FACTURER f2
       WHERE f2.CodeP = v2.CodeP
         AND f2.Mois = v2.Mois
         AND f2.Annee = v2.Annee
         AND v2.CodeE IN (
             -- Employés travaillant dans l'usine courante
             SELECT tu2.CodeE
             FROM TRAVAILLER_USINE tu2, DEPARTEMENTS d3
             WHERE tu2.CodeD = d3.CodeD
               AND d3.CodeU = u.CodeU
         )
   );
