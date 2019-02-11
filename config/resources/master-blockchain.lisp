(define-resource versioned-agenda ()
  :class (s-prefix "ext:VersionedAgenda")
  :properties `((:state :string ,(s-prefix "ext:stateString"))
                (:content :string ,(s-prefix "ext:content"))
                (:kind :string ,(s-prefix "ext:agendaKind")))
  :has-many `((signed-resource :via ,(s-prefix "ext:signsAgenda")
                               :inverse t
                               :as "signed-resources"))
  :has-one `((published-resource :via ,(s-prefix "ext:publishesAgenda")
                                 :inverse t
                                 :as "published-resource")
             (editor-document :via ,(s-prefix "prov:wasDerivedFrom")
                              :as "editor-document")
             (document-container :via ,(s-prefix "ext:hasVersionedAgenda")
                                 :inverse t
                                 :as "document-container"))
  :resource-base (s-url "http://lblod.info/presented-agendas/")
  :on-path "versioned-agendas")

(define-resource versioned-besluiten-lijst ()
  :class (s-prefix "ext:VersionedBesluitenLijst")
  :properties `((:state :string ,(s-prefix "ext:stateString"))
                (:content :string ,(s-prefix "ext:content")))
  :has-many `((signed-resource :via ,(s-prefix "ext:signsBesluitenlijst")
                               :inverse t
                               :as "signed-resources"))
  :has-one `((published-resource :via ,(s-prefix "ext:publishesBesluitenlijst")
                                 :inverse t
                                 :as "published-resource")
             (editor-document :via ,(s-prefix "prov:wasDerivedFrom")
                              :as "editor-document")
             (document-container :via ,(s-prefix "ext:hasVersionedBesluitenLijst")
                                 :inverse t
                                 :as "document-container"))
  :resource-base (s-url "http://lblod.info/presented-agendas/")
  :on-path "versioned-notulen")

(define-resource versioned-notulen ()
  :class (s-prefix "ext:VersionedNotulen")
  :properties `((:state :string ,(s-prefix "ext:stateString"))
                (:content :string ,(s-prefix "ext:content"))
                (:kind :string ,(s-prefix "ext:notulenKind")))
  :has-many `((signed-resource :via ,(s-prefix "ext:signsNotulen")
                               :inverse t
                               :as "signed-resources"))
  :has-one `((published-resource :via ,(s-prefix "ext:publishesNotulen")
                                 :inverse t
                                 :as "published-resource")
             (editor-document :via ,(s-prefix "prov:wasDerivedFrom")
                              :as "editor-document")
             (document-container :via ,(s-prefix "ext:hasVersionedNotulen")
                                 :inverse t
                                 :as "document-container"))
  :resource-base (s-url "http://lblod.info/presented-agendas/")
  :on-path "versioned-notulen")

(define-resource signed-resource ()
  :class (s-prefix "sign:SignedResource")
  :properties `((:content :string ,(s-prefix "sign:text"))
                (:created-on :datetime ,(s-prefix "dct:created")))
  :has-one `((blockchain-status :via ,(s-prefix "sign:status")
                                :as "status")
             (versioned-agenda :via ,(s-prefix "ext:signsAgenda")
                               :as "versioned-agenda")
             (gebruiker :via ,(s-prefix "sign:signatory")
                        :as "gebruiker"))
  :resource-base (s-url "http://lblod.info/signed-resources/")
  :on-path "signed-resources")

(define-resource published-resource ()
  :class (s-prefix "sign:PublishedResource")
  :properties `((:content :string ,(s-prefix "sign:text"))
                (:created-on :datetime ,(s-prefix "dct:created")))
  :has-one `((blockchain-status :via ,(s-prefix "sign:status")
                                :as "status")
             (versioned-agenda :via ,(s-prefix "ext:publishesAgenda")
                               :as "versioned-agenda")
             (gebruiker :via ,(s-prefix "sign:signatory")
                        :as "gebruiker"))
  :resource-base (s-url "http://lblod.info/published-resources/")
  :on-path "published-resources")

(define-resource blockchain-status ()
  :class (s-prefix "sign:BlockcainStatus")
  :properties `((:title :string ,(s-prefix "dct:title"))
                (:description :string ,(s-prefix "dct:description")))
  :resource-base (s-url "http://lblod.info/blockchain-statuses")
  :on-path "blockchain-statuses")
