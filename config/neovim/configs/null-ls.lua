local present, null_ls = pcall(require, "null-ls")
if not present then
	return
end

local b = null_ls.builtins

null_ls.setup({
	sources = {
		-- diagnostics
		b.diagnostics.actionlint,
		b.diagnostics.buf,
		b.diagnostics.buildifier,
		b.diagnostics.luacheck,
		b.diagnostics.eslint,
		b.diagnostics.shellcheck,
		b.diagnostics.terraform_validate,

		-- formatters
		b.formatting.alejandra,
		b.formatting.bean_format,
		b.formatting.black,
		b.formatting.buf,
		b.formatting.clang_format,
		b.formatting.deno_fmt,
		b.formatting.hclfmt,
		b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }),
		b.formatting.rustfmt,
		b.formatting.stylelua,
		b.formatting.taplo,
		b.formatting.terraform_fmt,
		b.formatting.zigfmt,
	},
})
