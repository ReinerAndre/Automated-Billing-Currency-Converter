# Guia de Operação: Automação de Câmbio e IVA

## Visão Geral
Este comando opera nos bastidores da tela de faturamento. Ao avançar com o fechamento do documento fiscal, o script executa a conversão baseada na cotação e aplica a proporção do IVA no valor final de cada item.

## Pré-requisitos
1. **Cotação Diária:** É obrigatório que a taxa de câmbio oficial do dia esteja cadastrada no sistema.
2. **Vínculo Comercial:** A Nota Fiscal deve ser originada de um Pedido de Venda devidamente emitido no ERP.

## Solução de Problemas
* **Erro:** `Verifique se tem pedido vinculado e/ou cotação cadastrada para o dia da emissão!`
  * **O que fazer:** Acesse a tela de moedas e garanta que existe cotação para o dia atual com a chave 'OFICIAL'. Se a cotação existir, confirme se a nota não foi feita avulsa (sem pedido).
* **Erro:** `Erro inesperado ao recalcular valor do item: [Detalhe]`
  * **O que fazer:** Tire um print ou copie o detalhe do erro ao final da mensagem e envie para o suporte de TI (Nível 2).
