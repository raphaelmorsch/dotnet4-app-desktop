using System;
using System.Drawing;
using System.Windows.Forms;
using CrudDesktop.Models;

namespace CrudDesktop.Forms
{
    public class ContatoForm : Form
    {
        private readonly TextBox _txtNome;
        private readonly TextBox _txtEmail;
        private readonly TextBox _txtTelefone;
        private readonly Button _btnSalvar;
        private readonly Button _btnCancelar;

        public Contato Contato { get; private set; }

        public ContatoForm(Contato contato = null)
        {
            Contato = contato ?? new Contato();

            Text = contato == null ? "Novo Contato" : "Editar Contato";
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;
            StartPosition = FormStartPosition.CenterParent;
            ClientSize = new Size(420, 220);

            var lblNome = new Label { Text = "Nome:", Location = new Point(20, 24), AutoSize = true };
            _txtNome = new TextBox
            {
                Location = new Point(120, 20),
                Size = new Size(270, 23),
                Text = Contato.Nome
            };

            var lblEmail = new Label { Text = "E-mail:", Location = new Point(20, 64), AutoSize = true };
            _txtEmail = new TextBox
            {
                Location = new Point(120, 60),
                Size = new Size(270, 23),
                Text = Contato.Email
            };

            var lblTelefone = new Label { Text = "Telefone:", Location = new Point(20, 104), AutoSize = true };
            _txtTelefone = new TextBox
            {
                Location = new Point(120, 100),
                Size = new Size(270, 23),
                Text = Contato.Telefone
            };

            _btnSalvar = new Button
            {
                Text = "Salvar",
                Location = new Point(210, 150),
                Size = new Size(85, 30),
                DialogResult = DialogResult.None
            };
            _btnSalvar.Click += BtnSalvar_Click;

            _btnCancelar = new Button
            {
                Text = "Cancelar",
                Location = new Point(305, 150),
                Size = new Size(85, 30),
                DialogResult = DialogResult.Cancel
            };

            AcceptButton = _btnSalvar;
            CancelButton = _btnCancelar;

            Controls.AddRange(new Control[]
            {
                lblNome, _txtNome,
                lblEmail, _txtEmail,
                lblTelefone, _txtTelefone,
                _btnSalvar, _btnCancelar
            });
        }

        private void BtnSalvar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(_txtNome.Text))
            {
                MessageBox.Show("Informe o nome do contato.", "Validação",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                _txtNome.Focus();
                return;
            }

            Contato.Nome = _txtNome.Text.Trim();
            Contato.Email = _txtEmail.Text.Trim();
            Contato.Telefone = _txtTelefone.Text.Trim();

            DialogResult = DialogResult.OK;
            Close();
        }
    }
}
