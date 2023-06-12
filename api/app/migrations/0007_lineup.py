# Generated by Django 4.2.1 on 2023-06-11 23:24

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0006_alter_festival_lat_alter_festival_lon_alter_user_lat_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='LineUp',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('artist', models.CharField(max_length=100)),
                ('start_time', models.TimeField()),
                ('end_time', models.TimeField()),
                ('stage', models.CharField(max_length=100)),
                ('day', models.IntegerField()),
                ('festival', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.festival')),
            ],
        ),
    ]
