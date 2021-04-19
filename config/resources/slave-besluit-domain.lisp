;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BESLUIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; this is a shared domain file, maintained in https://github.com/lblod/domain-files
(define-resource agendapunt ()
  :class (s-prefix "besluit:Agendapunt")
  :properties `((:beschrijving :string ,(s-prefix "dct:description"))
                (:gepland-openbaar :boolean ,(s-prefix "besluit:geplandOpenbaar"))
                (:heeft-ontwerpbesluit :url ,(s-prefix "besluit:heeftOntwerpbesluit"))
                (:titel :string ,(s-prefix "dct:title"))
                (:type :uri-set ,(s-prefix "besluit:Agendapunt.type"))
                (:position :int ,(s-prefix "schema:position")))
  :has-many `((agendapunt :via ,(s-prefix "dct:references")
                          :as "referenties")
              (published-resource :via ,(s-prefix "prov:wasDerivedFrom")
                                  :as "publications"))
  :has-one `((agendapunt :via ,(s-prefix "besluit:aangebrachtNa")
                         :as "vorige-agendapunt")
             (behandeling-van-agendapunt :via ,(s-prefix "dct:subject")
                                         :inverse t 
                                         :as "behandeling")
             (zitting :via ,(s-prefix "besluit:behandelt")
                      :inverse t
                      :as "zitting")
             (agenda :via ,(s-prefix "dct:isPartOf")
                     :inverse t
                     :as "agenda"
                     )
             )
  :resource-base (s-url "http://data.lblod.info/id/agendapunten/")
  :features '(include-uri)
  :on-path "agendapunten")

(define-resource artikel ()
  :class (s-prefix "besluit:Artikel")
  :properties `((:nummer :string ,(s-prefix "eli:number"))
                (:inhoud :string ,(s-prefix "prov:value"))
                (:taal :url ,(s-prefix "eli:language"))
                (:titel :string ,(s-prefix "eli:title"))
                (:page :url ,(s-prefix "foaf:page"))
                (:score :float ,(s-prefix "nao:score")))
  :has-one `((rechtsgrond-artikel :via ,(s-prefix "eli:realizes")
                                    :as "realisatie"))
  :resource-base (s-url "http://data.lblod.info/id/artikels/")
  :features '(include-uri)
  :on-path "artikels")

;;TODO how to relate to superclass 'Agent' for heeftAanwezige
(define-resource behandeling-van-agendapunt ()
  :class (s-prefix "besluit:BehandelingVanAgendapunt")
  :properties `((:openbaar :boolean ,(s-prefix "besluit:openbaar"))
                (:gevolg :string ,(s-prefix "besluit:gevolg"))
                (:afgeleid-uit :string ,(s-prefix "pav:derivedFrom"))
                (:position :int ,(s-prefix "schema:position")))
  :has-many `((besluit :via ,(s-prefix "prov:generated")
                       :as "besluiten")
              (mandataris :via ,(s-prefix "besluit:heeftAanwezige")
                          :as "aanwezigen")
              (mandataris :via ,(s-prefix "ext:heeftAfwezige")
                          :as "afwezigen")
              (stemming :via ,(s-prefix "besluit:heeftStemming")
                          :as "stemmingen"))
  :has-one `((behandeling-van-agendapunt :via ,(s-prefix "besluit:gebeurtNa")
                                         :as "vorige-behandeling-van-agendapunt")
             (agendapunt :via ,(s-prefix "dct:subject")
                              :as "onderwerp")
             (functionaris :via ,(s-prefix "besluit:heeftSecretaris")
                         :as "secretaris")
             (mandataris :via ,(s-prefix "besluit:heeftVoorzitter")
                         :as "voorzitter")
             (document-container :via , (s-prefix "ext:hasDocumentContainer")
                                  :as "document-container"))
  :resource-base (s-url "http://data.lblod.info/id/behandelingen-van-agendapunten/")
  :features '(include-uri)
  :on-path "behandelingen-van-agendapunten")

(define-resource besluit ()
  :class (s-prefix "besluit:Besluit")
  :properties `((:beschrijving :string ,(s-prefix "eli:description"))
                (:citeeropschrift :string ,(s-prefix "eli:title_short"))
                (:motivering :string ,(s-prefix "besluit:motivering"))
                (:publicatiedatum :date ,(s-prefix "eli:date_publication"))
                (:inhoud :string ,(s-prefix "prov:value"))
                (:taal :url ,(s-prefix "eli:language"))
                (:titel :string ,(s-prefix "eli:title"))
                (:score :float ,(s-prefix "nao:score")))
  :has-one `((rechtsgrond-besluit :via ,(s-prefix "eli:realizes")
                                  :as "realisatie")
             (behandeling-van-agendapunt :via ,(s-prefix "prov:generated")
                                         :inverse t
                                         :as "volgend-uit-behandeling-van-agendapunt")
             (besluitenlijst :via ,(s-prefix "ext:besluitenlijstBesluit")
                             :inverse t
                             :as "besluitenlijst"))
  :has-many `((published-resource :via ,(s-prefix "prov:wasDerivedFrom")
                                  :as "publications"))
  :resource-base (s-url "http://data.lblod.info/id/besluiten/")
  :features '(include-uri)
  :on-path "besluiten")

(define-resource bestuurseenheid ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel"))
                (:alternatieve-naam :string-set ,(s-prefix "skos:altLabel"))
                (:wil-mail-ontvangen :boolean ,(s-prefix "ext:wilMailOntvangen")) ;;Voorkeur in berichtencentrum
                (:mail-adres :string ,(s-prefix "ext:mailAdresVoorNotificaties")))
  :has-one `((werkingsgebied :via ,(s-prefix "besluit:werkingsgebied")
                             :as "werkingsgebied")
             (werkingsgebied :via ,(s-prefix "ext:inProvincie")
                             :as "provincie")
             (bestuurseenheid-classificatie-code :via ,(s-prefix "besluit:classificatie")
                                                 :as "classificatie"))
  :has-many `((contact-punt :via ,(s-prefix "schema:contactPoint")
                            :as "contactinfo")
              (bestuursorgaan :via ,(s-prefix "besluit:bestuurt")
                              :inverse t
                              :as "bestuursorganen"))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "bestuurseenheden"
)

(define-resource werkingsgebied ()
  :class (s-prefix "prov:Location")
  :properties `((:naam :string ,(s-prefix "rdfs:label"))
                (:niveau :string, (s-prefix "ext:werkingsgebiedNiveau")))

  :has-many `((bestuurseenheid :via ,(s-prefix "besluit:werkingsgebied")
                               :inverse t
                               :as "bestuurseenheid"))
  :resource-base (s-url "http://data.lblod.info/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "werkingsgebieden")

(define-resource bestuurseenheid-classificatie-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuurseenheidClassificatieCode/")
  :features '(include-uri)
  :on-path "bestuurseenheid-classificatie-codes")

(define-resource bestuursorgaan ()
  :class (s-prefix "besluit:Bestuursorgaan")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel"))
                (:binding-einde :date ,(s-prefix "mandaat:bindingEinde"))
                (:binding-start :date ,(s-prefix "mandaat:bindingStart")))
  :has-one `((bestuurseenheid :via ,(s-prefix "besluit:bestuurt")
                              :as "bestuurseenheid")
             (bestuursorgaan-classificatie-code :via ,(s-prefix "besluit:classificatie")
                                                :as "classificatie")
             (bestuursorgaan :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
                             :as "is-tijdsspecialisatie-van")
             (rechtstreekse-verkiezing :via ,(s-prefix "mandaat:steltSamen")
                                      :inverse t
                                      :as "wordt-samengesteld-door"))
  :has-many `((bestuursorgaan :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
                       :inverse t
                       :as "heeft-tijdsspecialisaties")
              (mandaat :via ,(s-prefix "org:hasPost")
                       :as "bevat")
              (bestuursfunctie :via ,(s-prefix "lblodlg:heeftBestuursfunctie")
                               :as "bevat-bestuursfunctie"))
  :resource-base (s-url "http://data.lblod.info/id/bestuursorganen/")
  :features '(include-uri)
  :on-path "bestuursorganen")

(define-resource bestuursorgaan-classificatie-code ()
  :class (s-prefix "ext:BestuursorgaanClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((bestuursfunctie-code :via ,(s-prefix "ext:hasDefaultType")
                                    :as "standaard-type")
              (bestuursorgaan :via ,(s-prefix "besluit:classificatie")
                              :inverse t
                              :as "is-classificatie-van"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/")
  :features '(include-uri)
  :on-path "bestuursorgaan-classificatie-codes")


;;TODO how to relate to superclass 'Rechtsgrond' for citeert/corrigeert/gecorrigeerd door/verandert/...
(define-resource rechtsgrond-besluit ()
  :class (s-prefix "eli:LegalResource")
  :properties `((:buitenwerkingtreding :date ,(s-prefix "eli:date_no_longer_in_force"))
                (:inwerkingtreding :date ,(s-prefix "eli:first_date_entry_in_force")))
  :has-many `((rechtsgrond-artikel :via ,(s-prefix "eli:has_part")
                                   :as "rechtsgronden-artikel"))
  :has-one `((bestuursorgaan :via ,(s-prefix "eli:passed_by")
                             :as "bestuursorgaan"))
  :resource-base (s-url "http://data.lblod.info/id/rechtsgronden-besluit/")
  :features '(include-uri)
  :on-path "rechtsgronden-besluit")

(define-resource rechtsgrond-artikel ()
  :class (s-prefix "eli:LegalResourceSubdivision")
  :properties `((:buitenwerkingtreding :date ,(s-prefix "eli:date_no_longer_in_force"))
                (:inwerkingtreding :date ,(s-prefix "eli:first_date_entry_in_force")))
  :has-one `((rechtsgrond-besluit :via ,(s-prefix "eli:has_part")
                                  :inverse t
                                  :as "rechtsgrond-besluit"))
  :resource-base (s-url "http://data.lblod.info/id/rechtsgronden-artikel/")
  :features '(include-uri)
  :on-path "rechtsgronden-artikel")

(define-resource stemming ()
  :class (s-prefix "besluit:Stemming")
  :properties `((:aantal-onthouders :number ,(s-prefix "besluit:aantalOnthouders"))
                (:aantal-tegenstanders :number ,(s-prefix "besluit:aantalTegenstanders"))
                (:aantal-voorstanders :number ,(s-prefix "besluit:aantalVoorstanders"))
                (:geheim :boolean ,(s-prefix "besluit:geheim"))
                (:title :string ,(s-prefix "dct:title"))
                (:gevolg :string ,(s-prefix "besluit:gevolg"))
                (:onderwerp :string ,(s-prefix "besluit:onderwerp")))
  :has-many `((mandataris :via ,(s-prefix "besluit:heeftAanwezige")
                          :as "aanwezigen")
              (mandataris :via ,(s-prefix "besluit:heeftOnthouder")
                          :as "onthouders")
              (mandataris :via ,(s-prefix "besluit:heeftStemmer")
                          :as "stemmers")
              (mandataris :via ,(s-prefix "besluit:heeftTegenstander")
                          :as "tegenstanders")
              (mandataris :via ,(s-prefix "besluit:heeftVoorstander")
                          :as "voorstanders"))
  :resource-base (s-url "http://data.lblod.info/id/stemmingen/")
  :features '(include-uri)
  :on-path "stemmingen")

(define-resource intermission ()
  :class (s-prefix "ext:Intermission")
  :properties `((:started-at :datetime ,(s-prefix "prov:startedAtTime"))
                (:ended-at :datetime ,(s-prefix "prov:endedAtTime"))
                (:comment :string ,(s-prefix "rdfs:comment")))
  :has-one `((zitting :via ,(s-prefix "ext:hasIntermission")
                      :inverse t
                      :as "zitting"))
  :resource-base (s-url "http://data.lblod.info/id/intermissions/")
  :features '(include-uri)
  :on-path "intermissions")

;;TODO how to relate to superclass 'Agent' for heeftAanwezige
(define-resource zitting ()
  :class (s-prefix "besluit:Zitting")
  :properties `((:geplande-start :datetime ,(s-prefix "besluit:geplandeStart"))
                (:gestart-op-tijdstip :datetime ,(s-prefix "prov:startedAtTime"))
                (:geeindigd-op-tijdstip :datetime ,(s-prefix "prov:endedAtTime"))
                (:op-locatie :string ,(s-prefix "prov:atLocation")))

  :has-many `((mandataris :via ,(s-prefix "besluit:heeftAanwezigeBijStart")
                          :as "aanwezigen-bij-start")
              (mandataris :via ,(s-prefix "ext:heeftAfwezigeBijStart")
                          :as "afwezigen-bij-start")
              (agendapunt :via ,(s-prefix "besluit:behandelt")
                          :as "agendapunten")
              (uittreksel :via ,(s-prefix "ext:uittreksel")
                          :as "uittreksels")
              (intermission :via ,(s-prefix "ext:hasIntermission")
                      :as "intermissions")
              (agenda :via ,(s-prefix "bv:isAgendaVoor")
                      :inverse t
                      :as "publicatie-agendas"))

  :has-one `((bestuursorgaan :via ,(s-prefix "besluit:isGehoudenDoor")
                             :as "bestuursorgaan")
             (functionaris :via ,(s-prefix "besluit:heeftSecretaris")
                         :as "secretaris")
             (mandataris :via ,(s-prefix "besluit:heeftVoorzitter")
                         :as "voorzitter")
             (notulen :via ,(s-prefix "besluit:heeftNotulen")
                      :as "notulen")
             (besluitenlijst :via ,(s-prefix "ext:besluitenlijst")
                             :as "besluitenlijst")
             (publication-status-code :via , (s-prefix "bibo:status")
                                  :as "publicatie-status"))
  :resource-base (s-url "http://data.lblod.info/id/zittingen/")
  :features '(include-uri)
  :on-path "zittingen")


(read-domain-file "slave-publicatie-gn-domain.lisp")
