# 1. Importamos a base diretamente do repositório no GitHub
library(readxl)

url <- "https://raw.githubusercontent.com/antoniohbueno/econometria1-renda-satisfacao-vida/main/Base_Felicidade.xlsx"
arquivo <- tempfile(fileext = ".xlsx")
download.file(url, destfile = arquivo, mode = "wb")

base <- read_excel(arquivo, sheet = "Consolidado")

# Aplicamos a transformação da variável do PIB per Capita
base$log_pib <- log(base$pib_pc)

# 2. Analisamos as estatísticas descritivas 

#Tabela 1: Estatísticas Descritivas
vars <- c("satisfacao", "pib_pc", "log_pib", "exp_vida",
          "desemprego", "corrupcao")
tabela1 <- data.frame(
  N          = sapply(base[, vars], length),
  Media      = sapply(base[, vars], mean),
  Desvio     = sapply(base[, vars], sd),
  Variancia  = sapply(base[, vars], var),
  Minimo     = sapply(base[, vars], min),
  Mediana    = sapply(base[, vars], median),
  Maximo     = sapply(base[, vars], max)
)
print(round(tabela1, 2))

# Tabela 2: Matriz de Correlação
vars_cor <- c("satisfacao", "log_pib", "exp_vida", "desemprego", "corrupcao")
tabela2 <- cor(base[, vars_cor])
print(round(tabela2, 2))

# 3. Estimamos os modelos de regressão
#adicionando gradualmente mais variáveis e de controle

m1 <- lm(satisfacao ~ log_pib, data = base)
summary(m1)

m2 <- lm(satisfacao ~ log_pib + exp_vida, data = base)
summary(m2)

m3 <- lm(satisfacao ~ log_pib + exp_vida + desemprego, data = base)
summary(m3)

m4 <- lm(satisfacao ~ log_pib + exp_vida + desemprego + corrupcao, data = base)
summary(m4)

# No modelo 5, controlamos por região com dummies
#os coeficientes comparam cada região à Europa e Ásia Central

base$regiao <- factor(base$regiao)
base$regiao <- relevel(base$regiao, ref = "Europa_AsiaCentral")

m5 <- lm(satisfacao ~ log_pib + exp_vida + desemprego + corrupcao + regiao,
         data = base)
summary (m5)

# 4. Testamos heterocedasticidade e utilizamos erros-padrão robustos
library(lmtest)
library(sandwich)
library(car)

# Teste de heterocedasticidade (Breusch-Pagan)
bptest(m1)
bptest(m2)
bptest(m3)
bptest(m4)
bptest(m5)

# Coeficientes com erros-padrao robustos HC1
coeftest(m1, vcov. = vcovHC(m1, type = "HC1"))
coeftest(m2, vcov. = vcovHC(m2, type = "HC1"))
coeftest(m3, vcov. = vcovHC(m3, type = "HC1"))
coeftest(m4, vcov. = vcovHC(m4, type = "HC1"))
coeftest(m5, vcov. = vcovHC(m5, type = "HC1"))

# Teste F robusto de significância conjunta das dummies de região
linearHypothesis(m5, c("regiaoAfricaSubsaariana = 0", 
                       "regiaoAmericaLatina = 0", 
                       "regiaoAmericaNorte = 0",
                       "regiaoLesteAsiatico = 0", 
                       "regiaoOrienteMedio_NorteAfrica = 0", 
                       "regiaoSulAsia = 0"),
                 white.adjust = "hc1")

# ==========================================================
#Figuras utilizadas ao longo do paper 

install.packages(c("ggplot2", "maps"))

library(ggplot2)
library(maps)

# Figura 1: Mapas da satisfação com a vida e do log do PIB per capita

# carregamos o mapa-múndi e retiramos a Antártida
mundo <- map_data("world")
mundo <- subset(mundo, region != "Antarctica")

# tabela que liga o código ISO3 da nossa base ao nome do país no mapa
codigos <- maps::iso3166
codigos$region <- sub("\\(.*", "", sub(":.*", "", codigos$mapname))
codigos <- unique(codigos[, c("a3", "region")])
names(codigos) <- c("codigo", "region")

# juntamos os dados da base ao mapa (países sem dados ficam em cinza)
dados_mapa <- merge(base, codigos, by = "codigo")
mapa <- merge(mundo, dados_mapa[, c("region", "satisfacao", "log_pib")],
              by = "region", all.x = TRUE)
mapa <- mapa[order(mapa$group, mapa$order), ]

# (a) mapa da satisfação com a vida
fig1a <- ggplot(mapa, aes(x = long, y = lat, group = group, fill = satisfacao)) +
  geom_polygon(colour = "white", linewidth = 0.1) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey85",
                       name = "Satisfação\ncom a vida") +
  coord_quickmap() +
  theme_void()
fig1a
ggsave("figura1a_mapa_satisfacao.png", fig1a, width = 8, height = 4, dpi = 300, bg = "white")

# (b) mapa do log do PIB per capita
fig1b <- ggplot(mapa, aes(x = long, y = lat, group = group, fill = log_pib)) +
  geom_polygon(colour = "white", linewidth = 0.1) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey85",
                       name = "Log do PIB\nper capita") +
  coord_quickmap() +
  theme_void()
fig1b
ggsave("figura1b_mapa_pib.png", fig1b, width = 8, height = 4, dpi = 300, bg = "white")

# Figura 2: Satisfação com a vida e log do PIB per capita

fig2 <- ggplot(base, aes(x = log_pib, y = satisfacao)) +
  geom_point(colour = "steelblue", size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", formula = y ~ x, colour = "black", fill = "grey80") +
  labs(x = "Log do PIB per capita (PPC)",
       y = "Satisfação com a vida (0 a 10)") +
  theme_minimal()
fig2
ggsave("figura2_dispersao.png", fig2, width = 7, height = 4.5, dpi = 300, bg = "white")

# Figura 3: Diferença de satisfação por região em relação à Europa 
#e Ásia Central (modelo 5)

# intervalos de confiança de 95% com erros-padrão robustos (HC1)
ic_m5 <- coefci(m5, vcov. = vcovHC, type = "HC1")

# selecionamos os coeficientes das dummies de região
dummies <- grep("^regiao", names(coef(m5)), value = TRUE)

efeito_regiao <- data.frame(
  regiao     = c("África Subsaariana", "América Latina e Caribe", "América do Norte",
                 "Leste Asiático e Pacífico", "Oriente Médio e Norte da África", "Sul da Ásia"),
  estimativa = coef(m5)[dummies],
  inferior   = ic_m5[dummies, 1],
  superior   = ic_m5[dummies, 2])

# ordenamos as regiões pelo tamanho do coeficiente
efeito_regiao$regiao <- reorder(efeito_regiao$regiao, efeito_regiao$estimativa)

fig3 <- ggplot(efeito_regiao, aes(x = estimativa, y = regiao)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_pointrange(aes(xmin = inferior, xmax = superior),
                  colour = "steelblue", size = 0.6) +
  labs(x = "Diferença de satisfação em relação à Europa e Ásia Central (pontos)",
       y = NULL) +
  theme_minimal()
fig3
ggsave("figura3_regioes.png", fig3, width = 7, height = 4, dpi = 300, bg = "white")

