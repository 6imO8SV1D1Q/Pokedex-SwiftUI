#!/usr/bin/env python3

import json
from collections import defaultdict

print("🔍 リージョンフォームの技継承を検証中...")
print()

# Load JSON
data = json.load(open('Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'))

# リージョンフォームと通常フォームをグループ化（chainId別）
chains_with_regionals = defaultdict(list)

for pokemon in data['pokemon']:
    evo_chain = pokemon.get('evolutionChain')
    if not evo_chain:
        continue

    chain_id = evo_chain.get('chainId')
    stage = evo_chain.get('evolutionStage', 1)

    # リージョンフォーム（ID > 10000）または通常フォームで、stage > 1のもの
    if stage > 1 or pokemon['id'] > 10000:
        chains_with_regionals[chain_id].append(pokemon)

# 進化ペアで技が不足しているケースをチェック
issues = []

for chain_id, pokemons in chains_with_regionals.items():
    # stage順にソート
    pokemons_sorted = sorted(pokemons, key=lambda p: (p['evolutionChain']['evolutionStage'], p['id']))

    for i in range(len(pokemons_sorted)):
        current = pokemons_sorted[i]
        current_stage = current['evolutionChain']['evolutionStage']

        if current_stage <= 1:
            continue

        # 同じchainIdで直前のstageのポケモンを探す
        pre_evos = [p for p in pokemons_sorted if p['evolutionChain']['evolutionStage'] == current_stage - 1]

        if not pre_evos:
            continue

        # 各進化前から技をチェック
        for pre_evo in pre_evos:
            pre_moves = {m['moveId'] for m in pre_evo['moves']}
            current_moves = {m['moveId'] for m in current['moves']}

            missing_moves = pre_moves - current_moves

            if missing_moves:
                # 技名を取得
                moves_dict = {m['id']: m for m in data['moves']}
                missing_names = [moves_dict[mid]['nameJa'] for mid in list(missing_moves)[:5]]

                issues.append({
                    'pre_evo': pre_evo,
                    'current': current,
                    'missing_count': len(missing_moves),
                    'missing_samples': missing_names
                })

# 結果表示
if not issues:
    print("✅ 全てのリージョンフォームで技が正しく継承されています！")
else:
    print(f"⚠️  {len(issues)}件の技継承漏れを発見しました:")
    print()

    for issue in issues[:20]:  # 最初の20件を表示
        pre = issue['pre_evo']
        cur = issue['current']
        print(f"  {pre['nameJa']} (ID: {pre['id']}, stage: {pre['evolutionChain']['evolutionStage']})")
        print(f"  → {cur['nameJa']} (ID: {cur['id']}, stage: {cur['evolutionChain']['evolutionStage']})")
        print(f"     不足技: {issue['missing_count']}個")
        print(f"     例: {', '.join(issue['missing_samples'])}")
        print()

    if len(issues) > 20:
        print(f"  ... 他 {len(issues) - 20} 件")

print()
print(f"検証完了: {len(chains_with_regionals)}個の進化チェーンをチェックしました")
