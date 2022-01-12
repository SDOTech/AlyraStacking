# Alyra Défi Staking

Le staking permet à un investisseur de gagner des intérêts ou des dividendes plutôt que de laisser ses cryptomonnaies « dormir » sans génération de bénéfices.

## Le stacking : 
Pour mettre en pratique ce concept vous allez devoir construire une Dapp qui permet aux utilisateurs de stake (immobiliser) n'importe quel token ERC20 et d'automatiser l'émission de récompenses aux stakers (fournisseurs de liquidité) sous la forme de tokens. 

La récompense en tokens reçues par les utilisateurs est un élément très important de votre Dapp. Elle doit être proportionnelle à la quantité des fonds bloqués sur le smart contract. Pour ce faire, vous avez besoin de la valeur marchande actuelle de l'actif bloqué, que vous pouvez récupérer en utilisant l’oracle de Chainlink.

L'obtention de données de prix à partir de Chainlink vous offre un moyen de comparer la valeur des tokens bloqués sur le smart contract. Vous pouvez facilement convertir la valeur de n'importe quel token ERC20 en sa valeur ETH afin de calculer et déterminer la valeur exacte de la récompense.

## Les spécifications fonctionnelles : 
- Stake son token ERC20 
- Unstake ses tokens 
- Créer son propre token de récompense ou utiliser l’ETH ou un autre token ERC20 (Dai par exemple) 
- La quantité de la récompense doit être proportionnelle à la valeur bloquées sur le smart contract 

Les exigences :
Utilisation de l’oracle Chainlink (https://chain.link/data-feeds)