
# Para além da renda: a influência das condições de vida sobre a satisfação com a vida entre países

**Autores:** Manuela Horta e Antonio Bueno  
**Instituição:** Escola de Economia de São Paulo da Fundação Getulio Vargas (FGV EESP)  
**Disciplina:** Econometria I (2026)  
**Repositório:** https://github.com/antoniohbueno/econometria1-renda-satisfacao-vida

---

## Descrição do Projeto

Este repositório reúne a base de dados consolidada e o script em R utilizados no trabalho final de Econometria I. O estudo investiga como a associação entre a renda per capita e a satisfação média com a vida entre países se altera quando outras dimensões da qualidade de vida e características regionais são consideradas. Para isso, estimam-se por Mínimos Quadrados Ordinários (MQO), com dados *cross-section* de 137 países e erros-padrão robustos à heterocedasticidade (HC1), cinco especificações encaixadas que acrescentam gradualmente ao logaritmo do PIB per capita a expectativa de vida ao nascer, a taxa de desemprego, o Índice de Percepção da Corrupção e variáveis *dummy* de região.

---

## Fontes dos Dados

A base final consolida indicadores públicos de 137 países, combinados pelo código ISO3:

* **Satisfação média com a vida (2023–2025):** Escada de Cantril (escala de 0 a 10), compilada pelo *Our World in Data* a partir do *World Happiness Report 2026* (Gallup World Poll).
* **PIB per capita em PPC (2025):** PIB per capita em paridade de poder de compra, a preços constantes de 2021 (US$ internacionais), obtido nos *World Development Indicators* (WDI) do Banco Mundial.
* **Expectativa de vida ao nascer (2024):** Expectativa de vida ao nascer, em anos, obtida nos *World Development Indicators* (WDI) do Banco Mundial.
* **Taxa de desemprego (2025):** Estimativas modeladas da Organização Internacional do Trabalho (OIT), em % da força de trabalho, disponibilizadas via Banco Mundial e *Our World in Data*.
* **Índice de Percepção da Corrupção (2025):** Escala de 0 (muito corrupto) a 100 (muito íntegro), publicado pela *Transparency International*.
* **Classificação regional (2025):** Divisão em sete regiões geográficas segundo o Banco Mundial.

---

## Arquivos Disponíveis

* `Base_Felicidade.xlsx`: Planilha Excel contendo a base de dados consolidada dos 137 países na aba `"Consolidado"`.
* `Trabalho Final Econometria (1).R`: Script em R contendo todo o código para importação dos dados, transformação de variáveis, cálculo das estatísticas descritivas e matriz de correlação, estimação dos cinco modelos de regressão, testes de diagnóstico (Breusch-Pagan, erros-padrão robustos HC1 e teste F conjunto) e geração das figuras do relatório.

---

## Pacotes Necessários em R

Para executar o script, são necessários os seguintes pacotes do R:

* `readxl` (importação da planilha `.xlsx`)
* `lmtest` (teste de Breusch-Pagan, `coeftest` e `coefci`)
* `sandwich` (matriz de covariância robusta `vcovHC` com ajuste `HC1`)
* `car` (teste F de restrições lineares conjuntas via `linearHypothesis`)
* `ggplot2` (construção dos mapas e gráficos)
* `maps` (malha cartográfica mundial e correspondência de códigos ISO3)

---

## Instruções para Execução do Script

1. Faça o download dos arquivos `Base_Felicidade.xlsx` e `Trabalho Final Econometria (1).R` para o seu computador.
2. Abra o arquivo `Trabalho Final Econometria (1).R` no R ou RStudio e defina o diretório de trabalho desejado (onde os arquivos `.png` das figuras serão salvos).
3. Caso algum dos pacotes listados não esteja instalado no seu ambiente, instale-o previamente com `install.packages(...)` (no script, há uma linha de instalação apenas para `ggplot2` e `maps` antes da seção das figuras).
4. Execute o script. Logo no início, a função `file.choose()` abrirá uma janela do sistema operacional para que você selecione manualmente o arquivo `Base_Felicidade.xlsx` (a leitura ocorre automaticamente na aba `"Consolidado"`).
5. Ao longo da execução, o console exibirá as tabelas descritivas, os resultados das cinco regressões e os testes de diagnóstico, enquanto os gráficos serão exportados em alta resolução (`.png`, 300 dpi) no diretório de trabalho atual.
