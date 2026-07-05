using System;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using CrudDesktop.Forms;
using CrudDesktop.Models;
using CrudDesktop.Services;

namespace CrudDesktop
{
    public class MainForm : Form
    {
        private readonly ContatoRepository _repository = new ContatoRepository();
        private readonly DataGridView _grid;
        private readonly Button _btnNovo;
        private readonly Button _btnEditar;
        private readonly Button _btnExcluir;
        private readonly Button _btnAtualizar;

        public MainForm()
        {
            Text = "CRUD de Contatos";
            StartPosition = FormStartPosition.CenterScreen;
            MinimumSize = new Size(700, 400);
            ClientSize = new Size(800, 450);

            _grid = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                RowHeadersVisible = false,
                BackgroundColor = SystemColors.Window
            };
            _grid.Columns.Add("Id", "Id");
            _grid.Columns.Add("Nome", "Nome");
            _grid.Columns.Add("Email", "E-mail");
            _grid.Columns.Add("Telefone", "Telefone");
            _grid.Columns["Id"].Visible = false;
            _grid.CellDoubleClick += (s, e) => EditarSelecionado();

            var panel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 50,
                Padding = new Padding(10)
            };

            _btnNovo = CriarBotao("Novo", 10);
            _btnEditar = CriarBotao("Editar", 100);
            _btnExcluir = CriarBotao("Excluir", 190);
            _btnAtualizar = CriarBotao("Atualizar", 280);

            _btnNovo.Click += (s, e) => NovoContato();
            _btnEditar.Click += (s, e) => EditarSelecionado();
            _btnExcluir.Click += (s, e) => ExcluirSelecionado();
            _btnAtualizar.Click += (s, e) => CarregarGrid();

            panel.Controls.AddRange(new Control[] { _btnNovo, _btnEditar, _btnExcluir, _btnAtualizar });

            Controls.Add(_grid);
            Controls.Add(panel);

            Load += (s, e) => CarregarGrid();
        }

        private static Button CriarBotao(string texto, int x)
        {
            return new Button
            {
                Text = texto,
                Location = new Point(x, 10),
                Size = new Size(80, 30)
            };
        }

        private void CarregarGrid()
        {
            _grid.Rows.Clear();
            foreach (var contato in _repository.Listar())
            {
                _grid.Rows.Add(contato.Id, contato.Nome, contato.Email, contato.Telefone);
            }
        }

        private Contato ObterSelecionado()
        {
            if (_grid.CurrentRow == null)
                return null;

            var id = (Guid)_grid.CurrentRow.Cells["Id"].Value;
            return _repository.Obter(id);
        }

        private void NovoContato()
        {
            using (var form = new ContatoForm())
            {
                if (form.ShowDialog(this) != DialogResult.OK)
                    return;

                _repository.Adicionar(form.Contato);
                CarregarGrid();
            }
        }

        private void EditarSelecionado()
        {
            var contato = ObterSelecionado();
            if (contato == null)
            {
                MessageBox.Show("Selecione um contato para editar.", "Aviso",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            using (var form = new ContatoForm(contato))
            {
                if (form.ShowDialog(this) != DialogResult.OK)
                    return;

                _repository.Atualizar(form.Contato);
                CarregarGrid();
            }
        }

        private void ExcluirSelecionado()
        {
            var contato = ObterSelecionado();
            if (contato == null)
            {
                MessageBox.Show("Selecione um contato para excluir.", "Aviso",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var confirmacao = MessageBox.Show(
                $"Deseja excluir o contato \"{contato.Nome}\"?",
                "Confirmar exclusão",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (confirmacao != DialogResult.Yes)
                return;

            _repository.Remover(contato.Id);
            CarregarGrid();
        }
    }
}
