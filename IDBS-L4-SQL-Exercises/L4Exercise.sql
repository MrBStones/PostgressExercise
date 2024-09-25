-- 1. Create a view AllAccountRecords that joins the Accounts and
-- AccountRecords and shows one entry for each record for each account.
-- The view should show all columns from both tables, first Accounts and
-- then AccountRecords, except the AccountRecords.AID column. Accounts
-- with no entry in AccountRecords should be shown with NULLs in the
-- columns for AccountRecords.
CREATE VIEW ALLACCOUNTRECORDS AS
SELECT
	*
FROM
	ACCOUNTS A
	FULL JOIN ACCOUNTRECORDS AR USING (AID);

-- 2. Create a trigger CheckBills for insertions to Bills that enforces a) that the
-- amount must be non-negative, and b) that the due date must be in the
-- future (tomorrow or later).
-- Optional: Forbid DELETE operations and allow UPDATE only on the bIsPaid
-- attribute. This is reflected in the test script.
CREATE FUNCTION CHECKBILLS () RETURNS TRIGGER AS $$ 
begin 
	if (TG_OP = 'DELETE') then
		raise exception
		'CheckBills: DELETE is not allowed'
		USING ERRCODE = '45002';
	end if;
	if (TG_OP = 'UPDATE') then
		if (old.bispaid = new.bispaid) then
			raise exception
			'CheckBills: UPDATE is only allowed for bIsPaid'
			USING ERRCODE = '45003';
		end if;
	end if;
	if (NEW.bamount <= 0) then
		raise exception
		'CheckBills: bAmount must be positive'
		USING ERRCODE = '45000';
	end if;
	if (NEW.bduedate <= now()::date) then 
		raise exception
		'CheckBills: bDueDate must be after today'
		USING ERRCODE = '45001';
	end if;
	return new;
end; $$ LANGUAGE PLPGSQL;

CREATE TRIGGER CHECKBILLS BEFORE INSERT OR UPDATE OR DELETE ON BILLS FOR EACH ROW
EXECUTE PROCEDURE CHECKBILLS ();

-- 3. Create a trigger on the AccountRecords table that does the following for
-- each insertion: a) checks whether the amount is available (taking the
-- overdraft into account) on the account being withdrawn from, b) updates
-- the balance on the account and c) installs the correct balance into the
-- AccountRecords entry.
-- Optional: Forbid DELETE and UPDATE operations. This is reflected in the
-- test script.
-- 4. Create a function Transfer, which takes three parameters, iToAID,
-- iFromAID, and iAmount, and transfers the given amount between the two
-- given accounts in a single transaction. If the amount is not available in the
-- iFromAID account, then the operation should be aborted (this should
-- happen via the trigger from #3). No return value.
-- Optional: Ensure that the transfer is non-negative. This is reflected in the
-- test script.
-- 5. Create a view DebtorStatus that shows, for each person whose total
-- balance is less than 0, the PID and pName of the person, the total balance
-- of all their accounts, and the total overdraft of all their accounts.
-- 6. Create a trigger NewPerson on People that creates a new account when a
-- new person is inserted to the table. The bank has a rule that each new
-- customer gets an initial overdraft of 10000.
-- 7. Create a function InsertPerson that takes four IN parameters iName,
-- iGender, iHeight, and iAmount. The function should insert a new person to
-- the People table, and then deposit the amount iAmount to the account
-- created by the trigger of #6. If you were unable to write the trigger of #6,
-- you can create the account in the function as well. No return value.
-- 8. Create a function PayOneBill that takes one parameter, iBID, and pays the
-- bill in question. The payment should come from the account with the
-- highest balance (including the overdraft) of the person’s accounts (if two
-- accounts have the same balance + overdraft, either one can be chosen).
-- The operations should of course rely on the trigger from #3 to maintain
-- consistency. If there are insufficient funds in a single account (including
-- the overdraft) to pay the bill, then the operation (transaction) should be
-- aborted. Of course, the bIsPaid field must be set to “true” for the bill. No
-- return value.
-- 9. Create a function LoanMoney, which takes three parameters iAID,
-- iAmount and iDueDate. The function should give the account a loan of
-- iAmount and also create a bill with the same iAmount and due date on
-- iDueDate. No return value.
-- 10. Create a view FinancialStatus that shows, for each person that has at least
-- one account, the PID and pName of the person, the total amount they have
-- on all their accounts, and the total amount of all unpaid bills.
-- Note: This is a complex view. You can solve it using two helper views. The
-- first helper view should sum up all accounts of every person, having one
-- entry for each person that has at least one account. The second helper view
-- should sum up all unpaid bills of every person, with one entry for each
-- person that has any unpaid bills. The final view should join the People table
-- with the two helper views, using an outer join for the second helper view.
-- The SQL function COALESCE might be useful to avoid returning NULL
-- values. The COALESCE function returns the first non-null value in a list
-- (see https://www.w3schools.com/sql/func_sqlserver_coalesce.asp).