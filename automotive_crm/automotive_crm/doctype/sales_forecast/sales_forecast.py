import frappe
from frappe.model.document import Document


class SalesForecast(Document):
    """Sales Forecast DocType controller"""

    def validate(self):
        self.calculate_variance()
        self.calculate_accuracy()

    def calculate_variance(self):
        """Calculate variance between forecast and actual"""
        if self.forecasted_volume and self.actual_volume:
            self.variance = self.actual_volume - self.forecasted_volume
            if self.forecasted_volume:
                self.variance_percentage = (self.variance / self.forecasted_volume) * 100

    def calculate_accuracy(self):
        """Calculate forecast accuracy"""
        if self.forecasted_volume and self.actual_volume:
            if self.forecasted_volume:
                self.accuracy = 100 - abs(self.variance) / self.forecasted_volume * 100

    def before_submit(self):
        """Before submit hook"""
        pass

    def on_update(self):
        """On update hook"""
        pass

    def on_trash(self):
        """On trash hook"""
        pass
