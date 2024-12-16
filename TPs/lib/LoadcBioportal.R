suppressPackageStartupMessages(library(cbioportalR))
suppressPackageStartupMessages(library(cBioPortalData))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(tibble))

bind_rows_smart <- function(data1, data2){
  vartypes1 <- setNames(lapply(colnames(data1), function(x) class(data1[[x]])), colnames(data1))
  vartypes2 <- setNames(lapply(colnames(data2), function(x) class(data2[[x]])), colnames(data2))
  vars_common <- intersect(names(vartypes1), names(vartypes2))
  for (var_common in vars_common){
    if (vartypes1[[var_common]]!=vartypes2[[var_common]]){
      data1[[var_common]] <- as.character(data1[[var_common]])
      data2[[var_common]] <- as.character(data2[[var_common]])
    }
  }

  bind_rows(data1, data2)
}



#' Load TCGA data using `cgdsr` R package interface to cBioPortal.
#'
#' @param StudyId Id(s) of the study(ies) you want to load. You can specify multiple studies by separating them with a
#' vertical separator "|" in a string. Optional if CancerTypeId is specified.
#' @param CancerTypeId Id(s) of the cancer type(s) you want to load. You can specify multiple cancer types by separating
#' them with a vertical separator "|" in a string. Optional if StudyId is specified.
#' @param Genes Character vector of gene names or entrez identifiers.
#' @param GenesType Choose 'hugoGeneSymbol' or 'entrezGeneId'.
#' @param ClinicNeeded Set to TRUE to load clinical data.
#' @param RNANeeded Set to TRUE to load RNA data.
#' @param MutNeeded Set to TRUE to load mutation data.
#' @param MutIgnoreGenes Set to TRUE to load all mutations regardless of the genes specified.
#' @param NormalizeRNA Set to TRUE to perform the normalization log((x-min(X))/(max(X)-min(X))+1) with X the vector of
#' expression profiles of gene x for all patients.
LoadcBioportal<-function(StudyId=NULL,
                         CancerTypeId=NULL,
                         Genes=c("TP53","KRAS"),
                         GenesType=c("hugoGeneSymbol", "entrezGeneId"),
                         ClinicNeeded=T,
                         RNANeeded=F,
                         MutNeeded=T,
                         MutIgnoreGenes=F,
                         NormalizeRNA=T){


  # input checks
  GenesType <- match.arg(GenesType, c("hugoGeneSymbol", "entrezGeneId"), several.ok=FALSE)

  ## initiate connection

  # cbioportalR
  base_url <- "www.cbioportal.org"
  set_cbioportal_db(db=base_url)

  # cBioPortalData
  cbio <- cBioPortal()

  ## list all cancer studies available

  # cbioportalR
  # DfCancerStudies <- cbp_api("studies", base_url=base_url)$content %>%
  #   dplyr::bind_rows(.) %>%
  #   select("studyId", everything())

  # cBioPortalData
  DfCancerStudies <- getStudies(api=cbio)

  # extract and transform if required
  normalized = function(x) {(x-min(x))/(max(x)-min(x))}

  if (!is.null(StudyId)){
    mycancerstudies <- DfCancerStudies[grepl(tolower(StudyId), tolower(DfCancerStudies$studyId)),]$studyId

    if(is.null(mycancerstudies)) {
      cat(paste("You should specify a study among:",
                  paste(sort(DfCancerStudies$studyId),collapse=", "), "\n" ))
      stop()
    }
  } else if (!is.null(CancerTypeId)){
    mycancerstudies <- DfCancerStudies[grepl(tolower(CancerTypeId), tolower(DfCancerStudies$cancerTypeId)),]$studyId

    if(is.null(mycancerstudies)) {
      cat(paste("You should specify a cancer type among:",
                  paste(sort(unique(DfCancerStudies$cancerTypeId)),collapse=", "), "\n"))
      stop()
    }
  } else {
      cat(paste("'StudyId' and 'CancerTypeId' cannot both be NULL!\n\n"))
      cat(paste("You should specify a cancer type among:\n",
                  paste(sort(unique(DfCancerStudies$studyId)),collapse=", ") ))
      cat(paste("\n\nor you should specify a cancer type among:\n",
                  paste(sort(unique(DfCancerStudies$cancerTypeId)),collapse=", ") ))
      stop()
  }

  print(paste("Pooling:", paste(mycancerstudies, collapse = " & ")))

  # cbioportalr
  if (!is.null(Genes)){
    if(GenesType=="hugoGeneSymbol") {
      EntrezGenes <- get_entrez_id(Genes, base_url=base_url)$entrezGeneId
    } else {
      EntrezGenes <- Genes
    }
  } else {
    EntrezGenes <- NULL
  }

  MUT<-data.frame()
  EXP<-data.frame()
  CLINIC<-data.frame()
  GenesNAS<-vector()
  STUDY<-data.frame(row.names = mycancerstudies)

  for(mycancerstudy in mycancerstudies){

    # cBioPortalData ===================================================================================================

    # # get sample lists
    # DfSampleLists <- sampleLists(api=cbio, studyId=mycancerstudy)
    # sampleListId <- DfSampleLists %>% filter(category=="all_cases_in_study") %>% pull(sampleListId)
    # mysamplelist <- samplesInSampleLists(api=cbio, sampleListIds=sampleListId)[[sampleListId]]

    # define the list of profiles required
    # get list of possible profiles
    n_retries <- 5
    i_try <- 1
    DfMolProfiles <- data.frame(error=character())
    while (i_try <= n_retries & "error" %in% colnames(DfMolProfiles)){
      DfMolProfiles <- molecularProfiles(api=cbio, studyId=mycancerstudy)
      i_try <- i_try + 1
    }
    mymolecularprofiles <- list()

    # if RNA required
    if (RNANeeded){
      mymolecularprofile <- DfMolProfiles %>%
        filter(molecularAlterationType=="MRNA_EXPRESSION", datatype=="CONTINUOUS") %>%
        pull(var="molecularProfileId")

      if (is.null(mymolecularprofile) | length(mymolecularprofile)==0){
        print(paste("No rnaseq v2 mrna for", mycancerstudy))
      } else {
        mymolecularprofiles[["rna"]] <- mymolecularprofile
      }
    }

    # # if Mut required
    # if (MutNeeded){
    #   mymolecularprofile <- DfMolProfiles %>%
    #     filter(molecularAlterationType=="MUTATION") %>%
    #     pull(var="molecularProfileId")

    #   if (is.null(mymolecularprofile) | length(mymolecularprofile)==0){
    #     print(paste("No mutation for", mycancerstudy))
    #   } else {
    #     mymolecularprofiles[["mut"]] <- mymolecularprofile
    #   }
    # }

    # # if MutExt required
    # if (MutExtNeeded){
    #   mymolecularprofile <- DfMolProfiles %>%
    #     filter(molecularAlterationType=="MUTATION_EXTENDED") %>%
    #     pull(var="molecularProfileId")

    #   if (is.null(mymolecularprofile) | length(mymolecularprofile)==0){
    #     print(paste("No mutation for", mycancerstudy))
    #   } else {
    #     mymolecularprofiles[["mutext"]] <- mymolecularprofile
    #   }
    # }

    # pull the data via cbioportalData
    cat(paste0("querying the following profiles for the study '", mycancerstudy, "':\n"))
    for (x in names(mymolecularprofiles)){
      cat(paste0("\t-", x, ": ", mymolecularprofiles[[x]]), "\n")
    }

    if (length(mymolecularprofiles)>0){
      cancerstudydata <- cBioPortalData(api=cbio, by="entrezGeneId", studyId=mycancerstudy, genes=EntrezGenes,
                                        molecularProfileIds=unlist(mymolecularprofiles))
    }

    # if (!is.null(mymolecularprofiles[["mut"]])){
    #   MUT1 <- assay(cancerstudydata, mymolecularprofiles[["mut"]])
    #   MUT1 <- MUT1 %>% as.data.frame() %>% rownames_to_column(var="case.id")
    #   MUT <- bind_rows_smart(MUT,MUT1)
    # }

    # if (!is.null(mymolecularprofiles[["mutext"]])){
    #   MUTEXT1 <- assay(cancerstudydata, mymolecularprofiles[["mutext"]])
    #   MUTEXT1 <- MUTEXT1 %>% as.data.frame() %>% rownames_to_column(var="case.id")
    #   MUTEXT <- bind_rows_smart(MUTEXT,MUTEXT1)
    # }

    if (!is.null(mymolecularprofiles[["rna"]])){
      EXP1 <- assay(cancerstudydata, mymolecularprofiles[["rna"]])
      for (X in colnames(EXP1)){
        EXP1[,X] <- sapply(EXP1[,X], function(x) {if(!is.numeric(x)){NA} else {x}})
      }
      NAS <- apply(EXP1, 1, function(Exp) any(is.na(Exp)))
      GenesNAS <- union(GenesNAS,Genes[NAS])

      if(NormalizeRNA){
        EXP1 <- normalized(log10(as.matrix(EXP1[!NAS,])+1))
      } else {
        EXP1 <- EXP1[!NAS,]
      }

      EXP1 <- EXP1 %>% t() %>% as.data.frame() %>% rownames_to_column(var="sampleId")
      EXP1 <- EXP1 %>% mutate(patientId=substr(sampleId, 1, 12)) %>% select(-sampleId)
      EXP <- bind_rows_smart(EXP,EXP1)
      STUDY[mycancerstudy,"RNA"] <- nrow(EXP1)
    }

    # # cbioportalR ====================================================================================================
    molecularprofiles <- available_profiles(study_id=mycancerstudy) %>%
      pull(molecularProfileId)

    # get patient lists
    mypatientlist <- available_patients(mycancerstudy)$patientId
    mysamplelist <- available_samples(mycancerstudy)$sampleId

    # get clinical data
    if(ClinicNeeded){
      myclinicaldata <- get_clinical_by_patient(patient_id=mypatientlist, study_id=mycancerstudy)
      myclinicaldata <- myclinicaldata %>% spread(clinicalAttributeId, value)
      STUDY[mycancerstudy,"Clinic"] <- nrow(myclinicaldata)
      myclinicaldata$study <- tolower(myclinicaldata$CANCER_TYPE_ACRONYM)
      CLINIC <- bind_rows_smart(CLINIC, myclinicaldata)
    }

    # get mutations in MAF format
    if(MutNeeded){
      molecularprofile <- molecularprofiles[grepl("mutations", molecularprofiles)]
      if (MutIgnoreGenes){
        genes <- NULL
      } else {
        genes <- EntrezGenes
      }
      MUT1 <- get_mutations_by_sample(sample_id=mysamplelist, genes=genes, molecular_profile_id=molecularprofile)
      MUT <- bind_rows_smart(MUT,MUT1)
      STUDY[mycancerstudy,"Mut"] <- nrow(MUT1)
    }

    # # get gene expression
    # if(RNANeeded){

    #   molecularprofiles <- available_profiles(study_id=mycancerstudy) %>%
    #     pull(molecularProfileId)
    #   molecularprofiles <- molecularprofiles[grepl("mrna", molecularprofiles)]
    #   molecularprofiles <- molecularprofiles[!grepl("Zscores", molecularprofiles)]

    #   if (length(molecularprofiles)>1){
    #     cat(paste("more than one RNA genetic profile withouth Zscore is available: ",
    #               paste(sort(molecularprofiles),collapse=", "), "\n" ))
    #     next()
    #   } else if (length(molecularprofiles)==0) {
    #     print(paste("No rnaseq v2 mrna for", mycancerstudy))
    #     next()
    #   } else
    #     # as indicated here https://groups.google.com/g/cbioportal/c/1XGHSwuX4J8/m/W-g0nL9jAQAJ, genetic profiles
    #     # rnaseq_v2_mrna on the cbioportal are extracted from .rsem.genes.normalized_results which contain only two
    #     # columns namely "gene_id" and "normalized_counts"
    #     # check this post to know normalized_counts are https://www.biostars.org/p/106127/

    #     # # TRY 1: does not work
    #     # sample_study_pairs <- data.frame(sample_id=mysamplelist)
    #     # sample_study_pairs$study_id <- mycancerstudy
    #     # sample_study_pairs$molecular_profile_id <- molecularprofiles
    #     # df_data <- get_genetics_by_sample(sample_study_pairs=sample_study_pairs, add_hugo=T)


    #     # # TRY 2: does not work either

    #     # body_api <- list(entrezGeneIds = EntrezGenes,
    #     #                 sampleIds = mysamplelist) %>%
    #     #             purrr::discard(is.null)

    #     # body_url <- paste0("molecular-profiles/", molecularprofiles, "/mrna-percentile/fetch?")
    #     # res <- cbp_api(url_path=body_url,
    #     #                method="post",
    #     #                body=body_api,
    #     #                base_url=base_url)
    #     # result <- purrr::map_dfr(res$content, ~purrr::list_flatten(.x))
    # }
  }

  # drop duplicates
  EXP <- EXP %>% distinct(patientId, .keep_all=T) %>% as.data.frame()

  if (nrow(CLINIC) > 0) CLINIC <- CLINIC %>% column_to_rownames(var="patientId") %>% as.data.frame()
  if (nrow(EXP) > 0) EXP <- EXP %>% column_to_rownames(var="patientId") %>% as.data.frame()
  if (nrow(MUT) > 0) MUT <- MUT %>% select(-uniqueSampleKey, -uniquePatientKey, -molecularProfileId)

  # set back to hugo symbol
  if (GenesType=="hugoGeneSymbol"){
    entrez2hugo <- setNames(get_hugo_symbol(entrez_id=colnames(EXP))$hugoGeneSymbol, colnames(EXP))
    colnames(EXP) <- entrez2hugo[colnames(EXP)]
  }

  TcgaData <- list(MUT=MUT, EXP=EXP, CLINIC=CLINIC, STUDY=STUDY)
  return(list(MUT=MUT, EXP=EXP, CLINIC=CLINIC, STUDY=STUDY))
}


# save RDS objects
CgcTable <- read.csv("../R_TP1/data/CancerGeneCensusCOSMIC_20240117.csv")
CgcGenes <- CgcTable$Gene.Symbol

# blca & lusc  exp
TcgaData <- LoadcBioportal(StudyId="blca_tcga_pan_can_atlas_2018|lusc_tcga_pan_can_atlas_2018",
                           Genes=CgcGenes,
                           GenesType="hugoGeneSymbol",
                           ClinicNeeded=T,
                           MutNeeded=F,
                           RNANeeded=T,
                           NormalizeRNA=T)
saveRDS(TcgaData, file="../R_TP1/data/blca_lusc_exp.RDS")

# lihc mut
TcgaData <- LoadcBioportal(StudyId="lihc_tcga_pan_can_atlas_2018",
                           Genes=NULL,
                           GenesType=NULL,
                           ClinicNeeded=T,
                           MutNeeded=T,
                           RNANeeded=F)

saveRDS(TcgaData, file="../R_TP2/data/lihc_mut_exp.RDS")



# blca brca hnsc lgg luad ov prad thca ucec  exp
tts <- c("blca", "brca", "hnsc", "lgg", "luad", "ov", "prad", "skcm", "thca", "ucec")
StudyId <- paste0(paste0(tts, "_tcga_pan_can_atlas_2018"), collapse="|")
TcgaData <- LoadcBioportal(StudyId=StudyId,
                           Genes=CgcGenes,
                           GenesType="hugoGeneSymbol",
                           ClinicNeeded=T,
                           MutNeeded=F,
                           RNANeeded=T,
                           NormalizeRNA=T)

# simplify
saveRDS(TcgaData, file="../R_TP1/data/ten_tumor_types_exp.RDS")
