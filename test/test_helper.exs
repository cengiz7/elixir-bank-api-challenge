ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Bank.Repo, :manual)

Mox.defmock(Bank.MockAccountsService, for: Bank.Accounts.Service)
Application.put_env(:bank, :accounts_service, Bank.MockAccountsService)
