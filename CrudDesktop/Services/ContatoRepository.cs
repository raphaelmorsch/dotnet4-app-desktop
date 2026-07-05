using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using CrudDesktop.Models;
using Newtonsoft.Json;

namespace CrudDesktop.Services
{
    public class ContatoRepository
    {
        private readonly string _filePath;
        private readonly List<Contato> _contatos;

        public ContatoRepository()
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            var folder = Path.Combine(appData, "CrudDesktop");
            Directory.CreateDirectory(folder);
            _filePath = Path.Combine(folder, "contatos.json");
            _contatos = Load();
        }

        public IReadOnlyList<Contato> Listar() => _contatos.OrderBy(c => c.Nome).ToList();

        public Contato Obter(Guid id)
        {
            return _contatos.FirstOrDefault(c => c.Id == id);
        }

        public void Adicionar(Contato contato)
        {
            _contatos.Add(contato);
            Salvar();
        }

        public void Atualizar(Contato contato)
        {
            var index = _contatos.FindIndex(c => c.Id == contato.Id);
            if (index < 0)
                throw new InvalidOperationException("Contato não encontrado.");

            _contatos[index] = contato;
            Salvar();
        }

        public void Remover(Guid id)
        {
            var contato = Obter(id);
            if (contato == null)
                return;

            _contatos.Remove(contato);
            Salvar();
        }

        private List<Contato> Load()
        {
            if (!File.Exists(_filePath))
                return new List<Contato>();

            var json = File.ReadAllText(_filePath);
            return JsonConvert.DeserializeObject<List<Contato>>(json) ?? new List<Contato>();
        }

        private void Salvar()
        {
            var json = JsonConvert.SerializeObject(_contatos, Formatting.Indented);
            File.WriteAllText(_filePath, json);
        }
    }
}
