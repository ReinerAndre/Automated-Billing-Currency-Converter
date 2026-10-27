DECLARE
  p_empresa          erp_faturamento_item.empresa_id%TYPE    := :p1;
  p_serie            erp_faturamento_item.serie_nota%TYPE    := :p2;
  p_nota             erp_faturamento_item.numero_nota%TYPE   := :p3;
  p_seq              erp_faturamento_item.sequencia_item%TYPE := :p4;
  v_retorno          VARCHAR2(1000)                          := NULL;
  
  v_emissao          erp_faturamento_capa.data_emissao%TYPE;
  v_valor            NUMBER;
  v_id_cotacao       erp_cotacao_moeda.cotacao_id%TYPE;
  v_cotacao          erp_cotacao_moeda.taxa_cambio%TYPE;
  v_pedido           erp_pedido_venda_item.numero_pedido%TYPE;
  v_item_pedido      erp_pedido_venda_item.sequencia_item%TYPE; 
  v_unitario_pedido  erp_pedido_venda_item.preco_unitario%TYPE; 
  v_moeda            erp_pedido_venda.moeda_id%TYPE;   
  
BEGIN
  IF p_empresa = 5 THEN
    -- 1. Busca os dados da nota e do pedido de venda vinculado
    SELECT item_fat.preco_unitario, capa_fat.data_emissao, vinculo.numero_pedido, vinculo.sequencia_pedido
      INTO v_valor, v_emissao, v_pedido, v_item_pedido
      FROM erp_faturamento_item item_fat
     INNER JOIN erp_faturamento_capa capa_fat
        ON capa_fat.empresa_id = item_fat.empresa_id
       AND capa_fat.serie_nota = item_fat.serie_nota
       AND capa_fat.numero_nota = item_fat.numero_nota
     INNER JOIN erp_faturamento_vinculo vinculo
        ON vinculo.empresa_id = item_fat.empresa_id
       AND vinculo.serie_nota = item_fat.serie_nota
       AND vinculo.numero_nota = item_fat.numero_nota
       AND vinculo.sequencia_nota = item_fat.sequencia_item
     WHERE item_fat.empresa_id = p_empresa
       AND item_fat.serie_nota = p_serie
       AND item_fat.numero_nota = p_nota
       AND item_fat.sequencia_item = p_seq;
             
    -- 2. Busca o valor unitário original na tabela de itens do pedido de venda
    SELECT preco_unitario
      INTO v_unitario_pedido
      FROM erp_pedido_venda_item item_ped
     WHERE item_ped.empresa_id = p_empresa
       AND item_ped.numero_pedido = v_pedido
       AND item_ped.sequencia_item = v_item_pedido;
       
    -- 3. Busca a moeda original do pedido de venda
    SELECT moeda_id
      INTO v_moeda
      FROM erp_pedido_venda capa_ped
     WHERE capa_ped.empresa_id = p_empresa
       AND capa_ped.numero_pedido = v_pedido;  
            
    -- 4. Busca a cotação oficial da moeda de destino na data de emissão
    SELECT cotacao_id, taxa_cambio
      INTO v_id_cotacao, v_cotacao
      FROM erp_cotacao_moeda 
     WHERE moeda_destino_id = 122 -- Moeda de destino configurada
       AND moeda_origem_id = v_moeda
       AND tipo_cotacao = 'OFICIAL'
       AND data_cotacao = v_emissao;
         
    -- 5. Atualiza o valor unitário convertido (com IVA) no item da nota fiscal
    UPDATE erp_faturamento_item SET
           preco_unitario = ROUND((v_cotacao * v_unitario_pedido), 4)
     WHERE empresa_id = p_empresa
       AND serie_nota = p_serie
       AND numero_nota = p_nota
       AND sequencia_item = p_seq;
         
    -- 6. Atualiza a referência da cotação utilizada na capa da nota fiscal
    UPDATE erp_faturamento_capa SET
           cotacao_id = v_id_cotacao
     WHERE empresa_id = p_empresa
       AND serie_nota = p_serie
       AND numero_nota = p_nota;
        
    v_retorno := 'Ok';
    :p5 := v_retorno;
  END IF;

EXCEPTION
  -- Trata a ausência de dados vitais para a conversão
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Verifique se tem pedido vinculado e/ou cotação cadastrada para o dia da emissão!');
    
  -- Previne que erros sistêmicos sejam ocultados
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'Erro inesperado ao recalcular valor do item: ' || SQLERRM);
END;