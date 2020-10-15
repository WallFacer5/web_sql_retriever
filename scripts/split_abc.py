import pandas as pd

if __name__ == '__main__':
    df = pd.read_csv('/Users/wallfacer/Documents/ABC_Retail.txt', sep='\t')
    employee = df[['Employee_LastName', 'Employee_FirstName', 'Employee_Title', 'CompanyName']]
    product = df[['ProductName', 'Order_UnitPrice']]
    customer = df[['Customer_ContactName', 'Customer_City', 'Customer_Country', 'Customer_Phone']]
    order = df[['OrderID', 'OrderDate', 'Order_ShippedDate', 'Order_Freight', 'Order_ShipCity', 'Order_ShipCountry',
                'Employee_LastName', 'Customer_ContactName']]
    order_products = df[['Order_Quantity', 'Order_Amount', 'OrderID', 'ProductName']]
    employee = employee.drop_duplicates(keep='first', inplace=False)
    product = product.drop_duplicates(keep='first', inplace=False)
    customer = customer.drop_duplicates(keep='first', inplace=False)
    order = order.drop_duplicates(keep='first', inplace=False)
    order_products = order_products.drop_duplicates(keep='first', inplace=False)
    employee.to_csv('/Users/wallfacer/Documents/employee.txt')
    product.to_csv('/Users/wallfacer/Documents/product.txt')
    customer.to_csv('/Users/wallfacer/Documents/customer.txt')
    order.to_csv('/Users/wallfacer/Documents/order.txt')
    order_products.to_csv('/Users/wallfacer/Documents/order_products.txt')
