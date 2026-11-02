Campo	              Regra
status	              open enquanto o registro for inválido; resolved quando passar a validação.
first_seen_at	      Data da primeira vez que o registro foi enviado à quarentena; não muda em atualizações.
last_seen_at	      Data da última execução em que o registro ainda foi observado como inválido. Não deve avançar quando ele for resolvido.
resolved_at	          NULL enquanto estiver open; recebe a data da resolução. Se voltar a ser inválido, retorna a NULL.