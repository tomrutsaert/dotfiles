-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
    'mfussenegger/nvim-jdtls',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    ft = 'java',
    config = function()
      local jdtls = require 'jdtls'

      -- Workspace directory for jdtls project data
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

      -- Find the jdtls installation from Mason
      local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
      local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

      -- Determine OS config
      local os_config
      if vim.fn.has 'mac' == 1 then
        os_config = 'config_mac'
      elseif vim.fn.has 'unix' == 1 then
        os_config = 'config_linux'
      else
        os_config = 'config_win'
      end

      -- Collect java-debug-adapter and java-test bundle JARs for DAP support
      local mason_path = vim.fn.stdpath 'data' .. '/mason/packages'
      local bundles = {}

      local java_debug_jar = vim.fn.glob(mason_path .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar')
      if java_debug_jar ~= '' then
        table.insert(bundles, java_debug_jar)
      end

      local java_test_jars = vim.split(vim.fn.glob(mason_path .. '/java-test/extension/server/*.jar'), '\n', { trimempty = true })
      vim.list_extend(bundles, java_test_jars)

      -- Extended capabilities for nvim-jdtls
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      local config = {
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xmx1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens', 'java.base/java.util=ALL-UNNAMED',
          '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          '-jar', launcher,
          '-configuration', jdtls_path .. '/' .. os_config,
          '-data', workspace_dir,
        },

        root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

        settings = {
          java = {
            format = {
              settings = {
                url = vim.fn.stdpath 'config' .. '/eclipse-doccle-formatter.xml',
                profile = 'Doccle',
              },
            },
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            inlayHints = {
              parameterNames = {
                enabled = 'all',
              },
            },
            signatureHelp = {
              enabled = true,
            },
            contentProvider = {
              preferred = 'fernflower',
            },
          },
        },

        init_options = {
          bundles = bundles,
          extendedClientCapabilities = extendedClientCapabilities,
        },

        on_attach = function(_, bufnr)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
          end

          -- Setup DAP (debug adapter)
          require('jdtls.dap').setup_dap { hotcodereplace = 'auto' }
          require('jdtls.dap').setup_dap_main_class_configs()

          -- Refactoring
          map('<leader>Jo', jdtls.organize_imports, 'Organize Imports')
          map('<leader>Jv', jdtls.extract_variable, 'Extract Variable')
          map('<leader>JV', jdtls.extract_variable_all, 'Extract Variable (all occurrences)')
          map('<leader>Jc', jdtls.extract_constant, 'Extract Constant')
          vim.keymap.set('v', '<leader>Jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], { buffer = bufnr, desc = 'Java: Extract Method' })

          -- Navigation
          map('<leader>Js', jdtls.super_implementation, 'Go to Super Implementation')

          -- Testing
          map('<leader>Jt', function() require('jdtls.dap').test_nearest_method() end, 'Test Nearest Method')
          map('<leader>JT', function() require('jdtls.dap').test_class() end, 'Test Class')
          map('<leader>Jk', function() require('jdtls.dap').pick_test() end, 'Pick Test')
          map('<leader>Jg', function() require('jdtls.tests').goto_subjects() end, 'Go to Test/Subject')
          map('<leader>JG', function() require('jdtls.tests').generate() end, 'Generate Test Stubs')

          -- Debugging
          map('<leader>Jd', function() require('dap').continue() end, 'Debug (Start/Continue)')

          -- Project
          map('<leader>Ju', jdtls.update_project_config, 'Update Project Config (reimport pom/gradle)')
          map('<leader>Jb', function() jdtls.compile 'full' end, 'Build Project')

          -- Tools
          map('<leader>Jp', jdtls.javap, 'Javap (show bytecode)')
          map('<leader>Jh', jdtls.jshell, 'Open JShell')
        end,
      }

      -- Attach to current buffer and all future Java buffers
      jdtls.start_or_attach(config)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          jdtls.start_or_attach(config)
        end,
      })
    end,
  },
}
