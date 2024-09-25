import psycopg as pg
import argparse
from configparser import ConfigParser
from pathlib import Path

############
# FUNCTIONS
############

def config(filename, section='postgresql'):
    """
    Read the values from database.ini
    Output: key-value object)
    """
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)
    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))
    return db



# NOTE: You can print statusmessage from a cursor 
#       after execute() to check the response from the database
#       example:
#       cur.execute()
#       print(cur.statusmessage)


# Task 1
def create_person_table(conn: pg.Connection):
    """
    Creates a table person. Drops it if it already exists.
    """
    try:
        # TODO: Add your code here
        print("haiii")
    except Exception as error:
        raise error


# Task 2
def insert_person(conn: pg.Connection, name: str, balance: int):
    """
    Inserts a new row into person
    """
    try:
        # TODO: Add your code here
        print()
    except Exception as error:
        raise error


# Task 3
def print_people(conn: pg.Connection):
    """
    Print all people in the person table.
    Output format is: name=<name>, balance=<balance>
    """
    try:
        # TODO: Add your code here
        print()
    except Exception as error:
        raise error


# Task 4
def get_balance_unsafe(conn:pg.Connection, name:str):
    """
    Fetches the balance of the person with the provided name
    This function is prone to SQL Injections
    """
    try:
        # TODO: Add your code here
        print()
    except Exception as error:
        raise error


# Task 5
def get_balance_safe(conn:pg.Connection, name:str):
    """
    Fetches the balance of the person with the provided name
    """
    try:
        # TODO: Add your code here
        print()
    except Exception as error:
        raise error

# Task 6
def set_balance(conn, name:str, balance:int):
    """
    Function to set the balance of a person
    """
    try:
        # TODO: Add your code here
        print() 
    except Exception as error:
        raise error


# Task 7
def transfer_money(conn, acc1:str, acc2:str, amount:int):
    """
    Transfer money between two accounts
    """
    try:
        # TODO: Add your code here
        print()
    except Exception as error:
        raise error


# Task 8
def transfer_money_with_transaction(conn: pg.Connection, acc1:str, acc2:str, amount:int, opt: bool, exc: bool):
    """
    Transfer money between two accounts using Transactions.
    """
    try:
        print('transfer_money_with_transaction: try')
        if opt:
            # METHOD 1: Transaction block, BEGIN is executed
            with conn.transaction():
                # Transfer (Uses a cursor to run multiple queries)
                transfer_money(conn, acc1, acc2, amount)
                # Let's pretend something went wrong
                if (exc):
                    raise Exception("Transaction failed due to unforseen circumstances")
            # COMMIT is executed at the end of the block if no exception is raised 
        else:
            # METHOD 2: Classic approach
            # When autocommit = False, nothing is committed until conn.commit() is called
            conn.autocommit = False
            # Use a cursor to run multiple queries
            # Transfer (Uses a cursor to run multiple queries)
            transfer_money(conn, acc1, acc2, amount)
            # Let's pretend something went wrong
            if (exc):
                raise Exception("Transaction failed due to unforseen circumstances")
            # Commit
            conn.commit()
    except Exception as error:
        print('transfer_money_tx: except')
        if not opt: 
            conn.rollback() # if this is ommitted, the changes would be committed once autocommit is enabled!
        raise error # propogate the exception ("exception bubbling") so the caller can know that something went wrong
    finally:
        # NOTE: Finally is always run, also when we throw the exception in the above catch-block
        print('transfer_money_tx: finally')
        if not opt:
            # Very important to return to autocommit
            conn.autocommit=True


########
# MAIN
########
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('ex', type=int, help="Specify the task number")
    parser.add_argument('--db-config', type=Path, default=Path('database.ini'))

    args = parser.parse_args()

    # Get database configuration
    cfg = config(args.db_config)
    connString = "host=%(host)s dbname=%(database)s user=%(user)s password=%(password)s" % (cfg)
    # Connect to the database
    try:
        # Start a new connection with autocommit enabled
        with pg.connect(connString, autocommit=True) as conn:
            if args.ex == 1:
                print('Creating Table Person')
                create_person_table(conn)
            elif args.ex == 2:
                print('Inserting people')
                insert_person(conn, 'Bruce', 1000000)
                insert_person(conn, 'Terry', 1000)
            elif args.ex == 3:
                print_people(conn)
            elif args.ex == 4:
                # NOTE: The variable has to be escaped to be passed into the string. If we pass just 'Bruce' it fails.
                balance = get_balance_unsafe(conn, "'Bruce'")
                print(balance) # 1000000
                balance = get_balance_unsafe(conn, "''; DELETE FROM person WHERE name='Bruce'; --")
                print(balance) # Nothing
                print_people(conn) # No more Bruce
            elif args.ex == 5:
                balance = get_balance_safe(conn, "Bruce")
                print(balance) # 1000
                balance = get_balance_safe(conn, "''; DELETE FROM person WHERE name='Bruce'; --") # Will raise an exception as no rows are returned
                print(balance) # None
            elif args.ex == 6:
                set_balance(conn, "Terry", 200)
                print_people(conn)
            elif args.ex == 7:
                transfer_money(conn, "Bruce", "Terry", 100)
                print_people(conn)
            elif args.ex == 8:
                print('-------')
                print('Transfer money using the with transactions() block style')
                transfer_money_with_transaction(conn, "Bruce", "Terry", 100, True, False) # No Exception (with transations())
                print_people(conn)
                print('-------')
                print('Transfer money using the try-except-finally style')
                transfer_money_with_transaction(conn, "Bruce", "Terry", 100, False, False) # No Exception (try-except-finally)
                print_people(conn)
                print('------')
                print('Raise an error before the end of the with block')
                try:
                    transfer_money_with_transaction(conn, "Bruce", "Terry", 100, True, True) # Raises exception before commit
                except Exception as error:
                    print(error)
                print_people(conn)
                print('------')
                print('Raise an error before conn.commit()')
                try:
                    transfer_money_with_transaction(conn, "Bruce", "Terry", 100, False, True) # Raises exception before commit
                except Exception as error:
                    print(error)
                print_people(conn)
                print('------')
            else:
                print("Incorrect task number provided. Select between [1-8].")
    except Exception as error:
        print(error)


