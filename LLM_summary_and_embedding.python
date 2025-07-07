# LLM-based MoA summarization
import ollama
import re

def summarize_moa(drug_name, description):
    import requests
    if description is None or description.strip() == "":
        summary = ""
    else:
        ollama_url = "http://localhost:11434/api/generate"
        prompt = f'''Summarize the mechanism of action of the drug {drug_name} in a single phrase based solely on the following description:       
{description} Do not use your own knowledge. Do not include any <think>...</think> block, thoughts or explanations.
'''
        payload = {"model": "deepseek-r1:8b"}
        response = requests.post(ollama_url, json=payload)
        summary = response.json()['response'].strip()
        summary = re.sub(r"<think>.*?</think>", "", summary, flags=re.DOTALL)
        summary = re.sub(r"\n+", " ", summary).strip()
    return summary

def get_embedding(text):
    response = ollama.embeddings(model='mxbai-embed-large', prompt=f'{text}')
    return response['embedding']
