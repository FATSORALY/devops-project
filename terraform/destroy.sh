#!/bin/bash
echo "🚨 Destruction complète de l'infrastructure (Free Tier)"
read -p "Es-tu sûr ? (yes/N) " confirm
if [[ $confirm == "yes" ]]; then
  terraform destroy -auto-approve
  echo "✅ Infrastructure détruite."
else
  echo "Annulé."
fi