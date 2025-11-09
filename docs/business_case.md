# 🧠 Business Case — Olist Realtime Pipeline (GCP)

## 1. Contexto do Negócio

A Olist é um e-commerce que centraliza a venda de produtos de diversos lojistas.  
Um dos principais desafios de operações desse tipo é **monitorar as vendas e o estoque em tempo real**,  
de forma que a empresa consiga:

- Identificar **rupturas de estoque** e agir antes que impactem o cliente final.  
- Acompanhar **receita e número de pedidos por categoria** minuto a minuto.  
- **Prever demanda** e ajustar campanhas de marketing.  
- Garantir que o fluxo de dados da operação seja **confiável, escalável e automatizado**.

---

## 2. Objetivo do Projeto

Desenvolver um **pipeline de dados em tempo real** utilizando a infraestrutura da **Google Cloud Platform (GCP)**,  
capaz de:

- Receber eventos de pedidos via **streaming** (Pub/Sub);
- Processar e limpar os dados automaticamente via **Cloud Functions**;
- Armazenar as informações brutas e transformadas no **BigQuery**;
- Criar modelos analíticos com **dbt** para consumo por ferramentas de BI;
- Exibir métricas executivas e operacionais no **Looker Studio (dashboard interativo)**.

---

## 3. Valor de Negócio

| Stakeholder | Benefício Direto |
|--------------|------------------|
| **Gestores de e-commerce** | Acompanham pedidos e receita em tempo real |
| **Time de supply chain** | Antecipam ruptura de estoque por categoria |
| **Time de marketing** | Medem o impacto imediato de campanhas |
| **Executivos** | Têm visão unificada do negócio em um painel único |

---

## 4. Principais KPIs

| KPI | Descrição |
|------|------------|
| **Pedidos Totais (orders)** | Volume total de vendas por minuto |
| **Receita Total (revenue)** | Soma do valor dos pedidos |
| **Ticket Médio** | Receita média por pedido |
| **Top Categorias** | Categorias com maior volume de vendas |
| **Pedidos por Minuto** | Frequência de eventos processados em tempo real |

---

## 5. Arquitetura Técnica

O pipeline foi construído com **componentes 100% serverless** da GCP:  
- **Pub/Sub** → mensageria em tempo real  
- **Cloud Functions** → transformação e ingestão automática  
- **BigQuery** → armazenamento e modelagem de dados  
- **dbt** → modelagem analítica e versionamento  
- **Looker Studio** → visualização e storytelling dos dados  

---

## 6. Impacto Esperado

- 🚀 **Redução de 90%** no tempo de atualização de métricas operacionais.  
- 🧭 **Centralização** de todas as métricas de vendas em um painel único.  
- 🔍 **Automação completa** do pipeline (sem tarefas manuais).  
- 📈 Base para futuros modelos de previsão de **churn e receita**.

---

## 7. Próximos Passos

- Implementar modelo preditivo (churn & receita) via **Vertex AI**.  
- Criar monitoramento de qualidade de dados (Data Quality).  
- Integrar logs de erro da Cloud Function ao **Stackdriver**.  
- Publicar documentação técnica e vídeo explicativo no portfólio.

---

📅 **Autor:**  
**Olavo Defendi Dalberto**  
Engenharia da Computação — UFSM
[olavodalberto921@gmail.com](mailto:olavodalberto921@gmail.com)
[GitHub](https://github.com/olavodd42) | [LinkedIn](https://www.linkedin.com/in/olavodalberto/)
