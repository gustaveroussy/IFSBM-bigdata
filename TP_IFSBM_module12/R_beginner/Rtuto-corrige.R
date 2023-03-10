## melina.gallopin@u-psud.fr
## TP du 3 d?cembre 2019

## Ex?cutez d'abord la commande de nettoyage de l'environnement

rm (list=ls())


####################################################################################
# Cours 1 : 
####################################################################################

# question 1
# Cr?er un vecteur nomm? "sel_var" contenant uniquement les chaines de caract?res 
# "disease", "gender" et "bmi"
# commande utile : c()

sel_var<-c("disease", "gender", "bmi")

# question 2 
# Cr?er un vecteur nomm? "sel_ind" contenant uniquement les entiers pairs entre 1 et 20
# commande utile : seq()

sel_ind <- seq(from=2,to=20,by=2)

# question 3 
# Cr?er un vecteur nomm? "sel_ind_alea" contenant 10 entiers s?lectionn?s al?atoirement 
# entre 1 et 10000
# commande utile : sample()

sel_ind_alea<-sample(1:1000,10)
  
# question 4
# Cr?er un vecteur de taille 100 contenant uniquement des 0 et des 1 tir?s al?atoirement.
# Repr?senter graphiquement la proportion de 0 et de 1 (il faut transformer les 0/1 en factor)
# et utiliser la commande plot() pour tracer le graphique. 

plot(factor(sample(0:1,100,replace=TRUE)))

# question 5 
# Afficher un vecteur compos? de 10 valeurs tir?es al?atoirement 
# sous une variable gaussienne de moyenne 0 et d'?cart-type 1. 
# Repr?senter graphiquement ces donn?es.
# commandes utiles : hist(), rnorm()

hist(rnorm(10,0,1))

# question 6
# Afficher un vecteur compos? de 100 valeurs tir?es al?atoirement 
# sous une variable gaussienne de moyenne 0 et d'?cart-type 1. 
# Repr?senter graphiquement ces donn?es.

hist(rnorm(100,0,1))

# question 7
# Afficher un vecteur compos? de 1000 valeurs tir?es al?atoirement 
# sous une variable gaussienne de moyenne 0 et d'?cart-type 1. 
# Repr?senter graphiquement ces donn?es.

hist(rnorm(1000,0,1))

####################################################################################
# Cours 2 : 
####################################################################################


# question 8 
# A l'aide du logiciel Excel (ou ?quivalent Open Office), cr?er un tableau de 5 colonnes 
# et 6 lignes. Donner des noms aux colonnes (ex : ? colonne 1 ?, ? colonne 2 ?, ., ? colonne 5 ?) 
# et aux lignes (ex : ? ligne 1 ?, ? ligne 2 ?, ., ? ligne 6 ?). 
# Remplir les cases du tableau comme vous le souhaitez.
# Sauvegarder ce tableau sous la forme d'un fichier texte (ou fichier CSV), 
# Importer le fichier texte obtenu dans une table R, en conservant 
# les noms des colonnes et les noms des lignes.
# (n?cessite sep="X", header = TRUE, row.names=1), o? X est le caract?re de s?paration du CSV 

table<-read.table("Classeur.csv", header=TRUE, sep=";")
table<-read.csv("Classeur.csv", header=TRUE )

# question 9 (optionnel niveau avanc?: pour t?l?charger vous m?me les donn?es avec TCGABiolinks) 
# En utilisant le package TCGAbiolinks disponible sur bioconductor, 
# t?l?charger les donn?es cliniques disponibles pour l'ensemble des patients
# (tout cancer confondu) pour les variables suivantes "submitter_id","disease",
# "gender", "race","ethnicity","days_to_death","tumor_stage","age_at_diagnosis",
# "weight","hieght","bmi","alcohol_history","years_smoked","year_of_diagnosis",
# "classification_of_tumor","cigarettes_per_day" et "morphology" 
sel_var <- c("submitter_id","disease","gender",
             "race","ethnicity","days_to_death",
             "tumor_stage","age_at_diagnosis",
             "weight","height","bmi","alcohol_history",
             "years_smoked","year_of_diagnosis","vital_status",
             "classification_of_tumor","cigarettes_per_day" ,"morphology")

## load package
library(TCGAbiolinks)

## get names of available  projects 
names_project <- TCGAbiolinks:::getGDCprojects()$project_id
## selection "TCGA" project names for all cancer 
names_project_TCGA <- names_project[grep("TCGA-",names_project)]

## choice of clinical variables
sel_var <- c("submitter_id","disease","gender",
             "race","ethnicity","days_to_death",
             "tumor_stage","age_at_diagnosis",
             "weight","height","bmi","alcohol_history",
             "years_smoked","year_of_diagnosis","vital_status",
             "classification_of_tumor","cigarettes_per_day" ,"morphology")
## NB : the number of clinical variables is not always the same for each type de cancer

## construct full table
full_table <- c()
for(nam in names_project_TCGA){
  clinical <- GDCquery_clinic(project = nam, type = "clinical")
  print(nam)
  print(paste0(c("nb obs :","nb var :"),dim(clinical)))
  full_table <- rbind(full_table,clinical[,sel_var])
}
## check dimension
colnames(clinical)
dim(full_table)
head(full_table)

## write table
write.table(full_table,file="clinical_all_tcga.txt")

# question 10 
# Charger les donn?es contenues dans le fichier clinical_all_tcga.txt 
# Stocker ces donn?es dans un tableau "clinic".
# commande utile : read.csv2() avec sep=" "

clinical<-read.csv2("clinical_all_tcga.txt",sep=" ") 

# question 11
# Quelle sont les dimensions du jeu de donn?es charg? ? 
# Combien d'invidus et combien de variables comporte le jeu de donn?es? 
# commande utile : dim()

dim(clinical)

# question 12 
# Afficher la valeur ligne 3, colonne 8
# Afficher toute la ligne 3
# Affichier les valeurs des lignes 1,7 et colonnes 3,9
# Afficher 

clinical[3,8]
clinical[3,]
clinical[c(1,7),c(3,9)]

# question 13
# Afficher le sous-tableau extrait du tableau "clinic" en selectionnant 
# uniquement les individus d'indices ?gaux aux indices stock?s dans le 
# vecteur "sel_ind_alea", et les colonnes stock?es dans le vecteur "sel_var"

clinical[sel_ind_alea,sel_var]

# question 14
# Combien de types de cancer sont r?pertori?s dans les donn?es ? 
# Combien d'observations (individus) par type de cancer sont disponibles ? 
# commandes utiles : length(), table(), unique()

length(unique(clinical$disease))
table(clinical$disease)

# question 15
# Afficher combien de patients ont un age au diagnostic > 80 ans
# (attention: l'age est en jours)
# commande utile: table
# Repr?senter l'?ge ? la date du diagnostic pour l'ensemble des patients
# commande utile : hist()

hist(clinical$age_at_diagnosis/365)

# question 16
# Ajouter l'age en ann?e arroundi ? la table clinic
# commande utile: round()

clinical$age3<-round(clinical$age_at_diagnosis/365)

# question 17
# Donner le type de chaque variable contenue dans la table "clinic"
# commande utile : str()

str(clinical)
  
# question 18
# Repr?senter graphiquement la distribution des variables "weight","height","bmi" et "cigarettes_per_day"
## NB: toutes ces variables sont de type "factor"
#   attention aux conversions "factor" <-> "numeric". cf exemple ci-dessous.
#   vous devez donc ajouter au tableau les variables transform?es avec as.numeric(as.character())
vect=c(7,18,2)
plot(vect)
data.class(vect)
vect_f=factor(vect)
plot(vect_f)
data.class(vect_f)
vect_f_n=as.numeric(vect_f)
vect_f_n # vect_f_n vaut 2 3 1 et non 7 18 2 !!!
plot(vect_f_n)
vect_f_c_n=as.numeric(as.character(vect_f))
vect_f_c_n # vect_f_n_c vaut bien 7 18 2 comme attendu

clinical$bmi3<-as.numeric(as.character(clinical$bmi))
clinical$weight3<-as.numeric(as.character(clinical$weight))
clinical$height3<-as.numeric(as.character(clinical$height))

# question 19
# repr?senter graphiquement le lien entre la variable "weight" et la variable "bmi"
plot(clinical$weight3,clinical$bmi3)

# question 20
# repr?senter graphiquement le lien entre la variable "weight" et la variable "height"
plot(clinical$weight3,clinical$height3)

# question 21
# repr?senter graphiquement le lien entre la variable "weight" et la variable "tumor_stage"
# commande: boxplot(variable ~ fact) o? fact est le facteur de s?paration ? utiliser
# on peut utiliser l'option las=2 pour afficher les labels verticalement
boxplot(clinical$weight3 ~ clinical$tumor_stage, las=2)

# NB : on ne "voit rien" sur ce premier graphique, car il y a des valeurs extr?mes...
# une solution pour mieux "voir" les donn?es est de prendre le log d'un ou 2 variables
boxplot(log(clinical$weight3) ~ clinical$tumor_stage, las=2)

# question 22
# repr?senter graphiquement le sexe ratio par type de cancer
plot(clinical$gender ~ clinical$disease)

# question 23
# repr?senter graphiquement les proportions relatives de la variable "ethnicity" par type de cancer
plot(clinical$ethnicity ~ clinical$disease)

# question 24
# repr?senter graphiquement l'ann?e du diagnostic en fonction du type de cancer
plot(clinical$year_of_diagnosis ~ clinical$disease,las=2)

# question 25
# repr?senter graphiquement le nombre de cigarettes consomm?es par jour en fonction de l'indice bmi 
plot(as.numeric(clinical$cigarettes_per_day),clinical$bmi3,ylim=c(0,80))
plot(log(as.numeric(clinical$cigarettes_per_day)),log(clinical$bmi3+1))

# question 26
# Repr?senter graphiquement la valeur de l'indice "bmi" en fonction du sexe
plot(clinical$bmi3 ~ clinical$gender, ylim=c(5,80))

# question 27
# Repr?senter graphiquement la distribution de l'?ge au diagnostic en fonction du type de cancer. 
plot(clinical$age3 ~ clinical$disease,las=2)

####################################################################################
# Cours 3 : 
####################################################################################
# question 28 
# Compter le nombre d'observations (individus) sans donn?es manquantes.
# commande utile : complete.cases()

table(complete.cases(clinical))
clinical[complete.cases(clinical),]

# question 29
# Compter le nombre d'observations pour lesquelles les variables "bmi" et "cigarettes_per_day"
# ne sont pas des valeurs manquantes
# (utilisez aussi complete.cases())

soustab <- clinical[,c("bmi","cigarettes_per_day")]
table(complete.cases(soustab))

# question 30
# Afficher le tableau des individus ayant une valeur de "bmi" sup?rieure ? 70
# inspirez-vous de ces exemples
monvect=1:10
monvect>5 
(monvect>6) | (monvect<3)
monvect[which((monvect>6) | (monvect<3))]

clinical[which(clinical$bmi3>70),]


# question 31
# Compter le nombre d'individus ayant un indice "bmi" sup?rieur ? 40 
# et fumant moins de 3 cigarettes par jour.

nrow(clinical[which(clinical$bmi3>40 & as.numeric(clinical$cigarettes_per_day)<3),])
nrow(clinical[which(clinical$bmi3>40),])

# question 32
# Donner la liste des cancers associ?s ? un indice "bmi" sup?rieur ? 40 
# et ? plus de 3 cigarettes par jour.

unique(clinical[which
                (clinical$bmi3>40 & as.numeric(clinical$cigarettes_per_day)>3),
                "disease"])

# question 33
# repr?senter graphiquement la taille chez les hommes, puis chez les femmes
# en r?alisant un graphique ? deux paneaux avec par(mfrow=c(1,2))
# commande: hist()
par(mfrow=c(1,2))
hist(clinical[clinical$gender=="male","height3"],xlim=c(140,200))
hist(clinical[clinical$gender=="female","height3"],xlim=c(140,200))

# question 34
# comparer la taille des hommes et des femmes
# commande: mean() avec option na.rm=TRUE
# testez la significativit? de la diff?rence
# commande: t.test

mean(clinical[clinical$gender=="male","height3"],na.rm=T)
mean(clinical[clinical$gender=="female","height3"],na.rm=T)

ga<-clinical[clinical$gender=="male","height3"]
fi<-clinical[clinical$gender=="female","height3"]
t.test(ga,fi,na.rm=T)
