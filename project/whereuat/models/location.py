from . import Model


class Location(Model):
    @staticmethod
    def update(user_id, longitude, latitude):
        return Location._upsert(
            'locations',
            'user_id',
            user_id=user_id,
            longitude=longitude,
            latitude=latitude
        )
